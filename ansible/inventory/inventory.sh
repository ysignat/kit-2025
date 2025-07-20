#!/usr/bin/env sh

yc compute instances list --jq \
    '{
        _meta: {
            hostvars: map(
                {
                    (.name): (
                        {
                            ansible_host: .network_interfaces[0].primary_v4_address.one_to_one_nat.address,
                        } + .labels
                    )
                }
            ) | add
        },
        all: {
            children: [
                .[].name | split("-")[0]
            ] | unique
        }
    } + (
        [
            group_by(.name | split("-")[0])[] | map(
                {
                    (.name | split("-")[0]): .name
                }
            )[]
        ] | 
        group_by(keys[0]) | 
        map(
            {
                (.[0] | keys[0]): map(.[])
            }
        ) | add
    )'
