# BE SURE TO log in as admin user first!

oc whoami --as=user1 >/dev/null  # This will only pass if user is cluster-admin
[ $? -ne 0 ] && echo "Please log in to the lab cluster as 'cluster-admin'" && exit 1

# Function to propagate the termination signal to all child processes
terminate_subprocesses() {
	 echo "Terminating all sub-processes..."
        pkill -P $$   # Sends the termination signal to all child processes
}

# Set the exit handler to call the terminate_subprocesses function
trap terminate_subprocesses EXIT

set -e

for u in {1..10}; do 
	echo Building images for user$u - See log file: /tmp/pre-build-images.user$u.log >&2
	echo "./pre-build-images user$u >/tmp/pre-build-images.user$u.log 2>&1"
done | xargs -P 5 -I {} sh -c "{}"

