#!/usr/bin/env sh
## AUTHOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NAME:
### 	cyber-do.sh.
## LICENSE:
###		GPLv3. <https://github.com/ciro-mota/cyber-do/blob/main/LICENSE>
## CHANGELOG:
### 	Last Update 03/09/2025. <https://github.com/ciro-mota/cyber-do/commits/main>

set -e

## Variables

listDropletsIds=$(doctl compute droplet list --format ID | tail -n +2)
listKuIds=$(doctl kubernetes cluster list --format ID | tail -n +2)
listVolumesIds=$(doctl compute volume list --format ID | tail -n +2)
listLoadBalancersIds=$(doctl compute load-balancer list --format ID | tail -n +2)
listDbIds=$(doctl databases list --format ID | tail -n +2)
# POSIX compatible tag list (space-separated)
tagName="prod Production PROD Prod"

## Check, preserve and delete VMs:

printf "\033[33;1mChecking for Droplets..\033[0m\n"

for idD in $listDropletsIds; do
	prodTagsDrop=$(doctl compute droplet get "$idD" --format Tags | tail -n +2)
	droptletName=$(doctl compute droplet get "$idD" --format Name | tail -n +2)
	matched=false

	for listTags in $tagName; do
		case "$prodTagsDrop" in
			"$listTags"*)
				echo "Preserving droptlet name: '$droptletName' with tagged: '$prodTagsDrop'"
				matched=true
				break
				;;
		esac
	done

	case "$droptletName" in
		*kube-cluster*)
			echo "Preserving droptlet name: '$droptletName' part of Kubernets cluster."
			matched=true
			;;
	esac

	if [ "$matched" = "false" ]; then
		echo "Deleting the droptlet with name: '$droptletName'"
		doctl compute droplet delete "$idD" -f
	fi
done

## Check, preserve and delete Kubernets:

printf "\033[33;1mChecking for Clusters Kubernets..\033[0m\n"

for idL in $listKuIds; do
	prodTagsKu=$(doctl kubernetes cluster get "$idL" --format Tags | tail -n +2)
	KuName=$(doctl kubernetes cluster get "$idL" --format Name | tail -n +2)
	matched=false

	oldIFS="$IFS"
	IFS=','
	set -- $prodTagsKu
	IFS="$oldIFS"

	for tag in "$@"; do
		tag=$(echo "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

		for listTags in $tagName; do
			if [ "$tag" = "$listTags" ]; then
				echo "Preserving cluster name: '$KuName' with tagged: '$prodTagsKu'"
				matched=true
				break 2
			fi
		done
	done

	if [ "$matched" = "false" ]; then
		echo "Deleting the cluster with name: '$KuName'"
		doctl kubernetes cluster delete --dangerous=true -f "$idL"
	fi
done

## Check, preserve and delete Volumes:

printf "\033[33;1mChecking for Volumes..\033[0m\n"

for idV in $listVolumesIds; do
	prodTagsV=$(doctl compute volume get "$idV" --format Tags | tail -n +2)
	volumeName=$(doctl compute volume get "$idV" --format Name | tail -n +2)
	matched=false

	oldIFS="$IFS"
	IFS=','
	set -- $prodTagsV
	IFS="$oldIFS"

	for tag in "$@"; do
		tag=$(echo "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

		for listTags in $tagName; do
			if [ "$tag" = "$listTags" ]; then
				echo "Preserving volume name: '$volumeName' with tagged: '$prodTagsV'"
				matched=true
				break 2
			fi
		done
	done

	if [ "$matched" = "false" ]; then
		echo "Deleting the volume with name: '$volumeName'"
		doctl compute volume delete -f "$idV"
	fi
done

## Check, preserve and delete Load Balancers:

printf "\033[33;1mChecking for Load Balancers..\033[0m\n"

for idB in $listLoadBalancersIds; do
	prodTagsLB=$(doctl compute load-balancer get "$idB" --format Tag | tail -n +2)
	LBName=$(doctl compute load-balancer get "$idB" --format Name | tail -n +2)
	matched=false

	for listTags in $tagName; do
		case "$prodTagsLB" in
			"$listTags"*)
				echo "Preserving Load Balancers name: '$LBName' with tagged: '$prodTagsLB'"
				matched=true
				break
				;;
		esac
	done

	if [ "$matched" = "false" ]; then
		echo "Deleting the Load Balancers with name: '$LBName'"
		doctl compute load-balancer delete -f "$idB"
	fi
done

## Check, preserve and delete Databases:

printf "\033[33;1mChecking for Databases..\033[0m\n"

for idDb in $listDbIds; do
	DbName=$(doctl databases get "$idDb" --format Name | tail -n +2)
	matched=false

	for clusterName in $DbName; do
		for substr in $tagName; do
			case "$clusterName" in
				*"$substr"*)
					echo "Preserving Database name '$clusterName' with tagged: '$substr'"
					matched=true
					break
					;;
			esac
		done
	done
	
	if [ "$matched" = "false" ]; then
		echo "Deleting the Database with name: $DbName"
		doctl databases delete -f "$idDb"
	fi

done

printf "\033[32;1mNothing more to do. \xE2\x9C\x94 \033[0m\n\n"