
# check tridentctl is on the system or not 
if ! [ -x "$(command -v tridentctl)" ]; then
  echo 'Error: tridentctl is not installed or not in the PATH.' >&2
  exit 1
fi


# list out the bouned pv which we do not want to delete 
pv_array=( $( oc get pv  --template='{{range .items}} {{if eq .status.phase "Bound"}} {{.metadata.name}}{{"\n"}}{{end}}{{end}}' --all-namespaces ))
tv_array=( $( tridentctl get volume -n trident -o name ))

# take out the volumes which are not part of pv_array , these will be removed in the loop 
mid_array=( $( echo  ${pv_array[@]} ${tv_array[@]} | tr ' ' '\n' | sort | uniq -u | sed /trident/d ))


for i in "${mid_array[@]}"
do
   echo " Volumes Name: $i   will be removed from the backend / netapp"
   tridentctl delete volume $i -n trident
   # or do whatever with individual element of the array
done
