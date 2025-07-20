package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/yandex-cloud/go-genproto/yandex/cloud/compute/v1"
	"github.com/yandex-cloud/go-genproto/yandex/cloud/operation"
	ycsdk "github.com/yandex-cloud/go-sdk"
)

const (
	InstanceName   = "webserver-testing-03"
	HostName       = InstanceName
	Zone           = "ru-central1-b"
	SubnetId       = "e2ljl24ccso919i55gej" // default-ru-central1-b
	MetadataPath   = "../cloud-init-minion.yml"
	ImageId        = "fd88h22en6kf0uhptpk5" // Ubuntu 20.04
	StandardImages = "standard-images"
	DiskSize       = 20 * 1024 * 1024 * 1024 // 20GB in bytes
	Memory         = 2 * 1024 * 1024 * 1024  // 2GB in bytes
	Cores          = 2
	CoreFraction   = 100
	DiskType       = "network-ssd"
	PlatformID     = "standard-v2"
	FolderId       = "b1gd9grok106is5l1uuj"
	TokenEnv       = "YC_TOKEN"
)

func main() {
	ctx := context.Background()

	token, ok := os.LookupEnv(TokenEnv)
	if !ok {
		log.Fatalf("Missing %s environment variable", TokenEnv)
	}

	sdk, err := ycsdk.Build(ctx, ycsdk.Config{
		Credentials: ycsdk.NewIAMTokenCredentials(token),
	})
	if err != nil {
		log.Fatalf("Failed to initialize SDK: %v", err)
	}

	metadata, err := readMetadata(MetadataPath)
	if err != nil {
		log.Fatalf("Failed to read SSH key: %v", err)
	}

	op, err := sdk.WrapOperation(createInstance(ctx, sdk, FolderId, ImageId, SubnetId, metadata))
	if err != nil {
		log.Fatalf("Failed to schedule operation: %v", err)
	}

	fmt.Printf("Running Yandex.Cloud operation. ID: %s\n", op.Id())

	err = op.Wait(ctx)
	if err != nil {
		log.Fatalf("Error while waiting for operation: %v", err)
	}

	resp, err := op.Response()
	if err != nil {
		log.Fatalf("Failed to marshall operation response: %v", err)
	}

	instance := resp.(*compute.Instance)
	fmt.Printf("Instance with id %s was created\n'", instance.Id)
}

func readMetadata(path string) (string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", fmt.Errorf("failed to read metadata file: %v", err)
	}
	return strings.TrimSpace(string(data)), nil
}

func createInstance(ctx context.Context, sdk *ycsdk.SDK, folderID, imageID, subnetID, metadata string) (*operation.Operation, error) {
	instanceService := sdk.Compute().Instance()

	metadata_map := map[string]string{
		"user-data": metadata,
	}

	req := &compute.CreateInstanceRequest{
		FolderId:   folderID,
		Name:       InstanceName,
		Hostname:   HostName,
		ZoneId:     Zone,
		PlatformId: PlatformID,
		ResourcesSpec: &compute.ResourcesSpec{
			Cores:        Cores,
			Memory:       Memory,
			CoreFraction: CoreFraction,
		},
		BootDiskSpec: &compute.AttachedDiskSpec{
			Mode:       compute.AttachedDiskSpec_READ_WRITE,
			AutoDelete: true,
			Disk: &compute.AttachedDiskSpec_DiskSpec_{
				DiskSpec: &compute.AttachedDiskSpec_DiskSpec{
					Size:   DiskSize,
					TypeId: DiskType,
					Source: &compute.AttachedDiskSpec_DiskSpec_ImageId{
						ImageId: imageID,
					},
				},
			},
		},
		NetworkInterfaceSpecs: []*compute.NetworkInterfaceSpec{
			{
				SubnetId: subnetID,
				PrimaryV4AddressSpec: &compute.PrimaryAddressSpec{
					OneToOneNatSpec: &compute.OneToOneNatSpec{
						IpVersion: compute.IpVersion_IPV4,
					},
				},
			},
		},
		Metadata: metadata_map,
		SchedulingPolicy: &compute.SchedulingPolicy{
			Preemptible: true,
		},
		Labels: map[string]string{
			"ansible_python_interpreter":   "/usr/bin/python3.8",
			"ansible_ssh_private_key_file": ".ssh/ansible.ed25519",
			"ansible_user":                 "yc-user",
			"nginx_version":                "1.28.0",
		},
	}

	fmt.Println("Creating instance...")
	op, err := instanceService.Create(ctx, req)

	return op, err
}
