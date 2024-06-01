#!/usr/bin/env bash
## AUTHOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NAME:
### 	cyber-do.sh.
## LICENSE:
###		GPLv3. <https://github.com/ciro-mota/cyber-do/blob/main/LICENSE>
## CHANGELOG:
### 	Last Update 01/06/2024. <https://github.com/ciro-mota/cyber-do/commits/main>

set -e

## Variables
listDropletsIds=$(doctl compute droplet list --format ID | tail -n +2)
listKuIds=$(doctl kubernetes cluster list --format ID | tail -n +2)
listVolumesIds=$(doctl compute volume list --format ID | tail -n +2)
listLoadBalancersIds=$(doctl compute load-balancer list --format ID | tail -n +2)
listDbIds=$(doctl databases list --format ID | tail -n +2)
tagName=("prod"
	"Production"
	"PROD"
	"Prod")

## Check, preserve and delete VMs:
# shellcheck disable=SC2034

echo -e "\e[33;1mChecking for Droplets..\e[m"

for idD in $listDropletsIds; do
	prodTagsDrop=$(doctl compute droplet get "$idD" --format Tags | tail -n +2)
	droptletName=$(doctl compute droplet get "$idD" --format Name | tail -n +2)
	matched=false

	for listTags in "${tagName[@]}"; do
		if [[ "$prodTagsDrop" == "$listTags"* ]]; then
			echo "Preserving droptlet name: '$droptletName' with tagged: '$prodTagsDrop'"
			matched=true
			break
		fi
	done

	if [[ "$droptletName" == *kube-cluster* ]]; then
			echo "Preserving droptlet name: '$droptletName' part of Kubernets cluster."
			matched=true
			break
		fi

	if [ "$matched" = false ]; then
		echo "Deleting the droptlet with name: '$droptletName'"
		doctl compute droplet delete "$idD" -f
	fi
done

## Check, preserve and delete Kubernets:

echo -e "\e[33;1mChecking for Clusters Kubernets..\e[m"

for idL in $listKuIds; do
	prodTagsKu=$(doctl kubernetes cluster get "$idL" --format Tags | tail -n +2)
	KuName=$(doctl kubernetes cluster get "$idL" --format Name | tail -n +2)
	matched=false

	IFS=',' read -r -a tagList <<< "$prodTagsKu"
	result=""

	for tag in "${tagList[@]}"; do
	tag=$(echo "$tag" | xargs)

		for listTags in "${tagName[@]}"; do
			if [[ "$tag" == "$listTags" ]]; then
				echo "Preserving cluster name: '$KuName' with tagged: '$prodTagsKu'"
				matched=true
				break 2
			fi
		done
	done

	if [ "$matched" = false ]; then
		echo "Deleting the cluster with name: '$KuName'"
		doctl kubernetes cluster delete --dangerous=true -f "$idL"
	fi
done

## Check, preserve and delete Volumes:

echo -e "\e[33;1mChecking for Volumes..\e[m"

for idV in $listVolumesIds; do
	prodTagsV=$(doctl compute volume get "$idV" --format Tags | tail -n +2)
	volumeName=$(doctl compute volume get "$idV" --format Name | tail -n +2)
	matched=false

	IFS=',' read -r -a tagList <<< "$prodTagsV"
	# shellcheck disable=SC2034
	result=""

	for tag in "${tagList[@]}"; do
	tag=$(echo "$tag" | xargs)

		for listTags in "${tagName[@]}"; do
			if [[ "$tag" == "$listTags" ]]; then
				echo "Preserving volume name: '$volumeName' with tagged: '$prodTagsV'"
				matched=true
				break 2
			fi
		done
	done

	if [ "$matched" = false ]; then
		echo "Deleting the volume with name: '$volumeName'"
		doctl compute volume delete -f "$idV"
	fi
done

## Check, preserve and delete Load Balancers:

echo -e "\e[33;1mChecking for Load Balancers..\e[m"

for idB in $listLoadBalancersIds; do
	prodTagsLB=$(doctl compute load-balancer get "$idB" --format Tag | tail -n +2)
	LBName=$(doctl compute load-balancer get "$idB" --format Name | tail -n +2)
	matched=false

	for listTags in "${tagName[@]}"; do
		if [[ "$prodTagsLB" == "$listTags"* ]]; then
			echo "Preserving Load Balancers name: '$LBName' with tagged: '$prodTagsLB'"
			matched=true
			break
		fi
	done

	if [ "$matched" = false ]; then
		echo "Deleting the Load Balancers with name: '$LBName'"
		doctl compute load-balancer delete -f "$idB"
	fi
done

## Check, preserve and delete Databases:

echo -e "\e[33;1mChecking for Databases..\e[m"

for idDb in $listDbIds; do
	DbName=$(doctl databases get "$idDb" --format Name | tail -n +2)
	matched=false

	for clusterName in $DbName; do
		for substr in "${tagName[@]}"; do
			if [[ "$clusterName" == *"$substr"* ]]; then
				echo "Preserving Database name '$clusterName' with tagged: '$substr'"
				matched=true
				break
			fi
		done
	done
	
	if [ "$matched" = false ]; then
		echo "Deleting the Database with name: $DbName"
		doctl databases delete -f "$idDb"
	fi

done

echo -e "\e[32;1mNothing more to do. \xE2\x9C\x94 \e[m\n"
