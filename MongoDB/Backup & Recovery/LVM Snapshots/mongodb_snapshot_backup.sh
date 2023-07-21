#!/bin/bash
#mongodb_snapshot_backup.sh

# MongoDB configuration
MONGODB_USER="backup_admin"
MONGODB_PASS="secret"
MONGODB_PORT="27001"

# LVM configuration
LVM_VOLUME="lvmongo"
VOLUME_GROUP="vg_mongo"
SNAPSHOT_NAME="mongosnap_$(date +'%Y%m%d%H%M%S')" # Append date and time to the snapshot name

# Backup directory
BACKUP_DIR="/backup"

# HTML and text log files
HTML_LOG_FILE="/backup_logs/backup_logs.html"
TEXT_LOG_FILE="/backup_logs/backup_logs.txt"

# Oplog position file
OPLOG_POS_FILE="$BACKUP_DIR/oplogposition_mongosnap_$(date +'%Y%m%d%H%M%S').pos"

# Function to log messages to both HTML and text files
log() {
    local log_message=$1
    local log_color=$2
    echo "$(date +'%Y-%m-%d %H:%M:%S') $log_message" >> "$TEXT_LOG_FILE"
    echo "<p style=\"color: $log_color;\">$(date +'%Y-%m-%d %H:%M:%S') $log_message</p>" >> "$HTML_LOG_FILE"
}

# Function to lock the MongoDB database with fsynclock
lock_mongodb() {
    log "Locking MongoDB database with fsynclock" "green"
    if ! mongo --username="$MONGODB_USER" --password="$MONGODB_PASS" --authenticationDatabase="admin" --port="$MONGODB_PORT" --eval "db.fsyncLock()" &>/dev/null; then
        log "Failed to lock MongoDB database. Check MongoDB status and authentication." "red"
        exit 1
    fi
}

# Function to record oplog position
record_oplog_position() {
    log "Recording oplog position before backup" "green"
    local_oplog_position=$(mongo --username="$MONGODB_USER" --password="$MONGODB_PASS" --authenticationDatabase="admin" --port="$MONGODB_PORT" --quiet --eval 'var local = db.getSiblingDB("local"); var last = local["oplog.rs"].find().sort({ "$natural": -1 }).limit(1)[0]; if (last != null) { result = { position: last["ts"] }; } else { result = { position: null }; } print(JSON.stringify(result));')
    echo "$local_oplog_position" > "$OPLOG_POS_FILE"
}

# Function to create the LVM snapshot
create_snapshot() {
    log "Creating LVM snapshot: $SNAPSHOT_NAME" "green"
    if ! sudo lvcreate -L1G -s -n "$SNAPSHOT_NAME" "/dev/$VOLUME_GROUP/$LVM_VOLUME"; then
        log "Failed to create LVM snapshot: $SNAPSHOT_NAME" "red"
        unlock_mongodb
        exit 1
    fi
}

# Function to mount the LVM snapshot with specified options
mount_snapshot() {
    local mountpoint="/tmp/$SNAPSHOT_NAME"

    log "Mounting LVM snapshot to $mountpoint with options" "green"
    sudo mkdir -p "$mountpoint"
    if sudo mount -t xfs -o nouuid,ro "/dev/$VOLUME_GROUP/$SNAPSHOT_NAME" "$mountpoint"; then
        log "LVM snapshot mounted successfully to $mountpoint" "green"
    else
        log "Failed to mount LVM snapshot to $mountpoint" "red"
        unlock_mongodb
        exit 1
    fi
}

# Function to back up the LVM snapshot
backup_lvm_snapshot() {
    local mountpoint="/tmp/$SNAPSHOT_NAME"
    local backup_file="$BACKUP_DIR/mongosnap_$(date +'%Y%m%d%H%M%S').tar.gz"
    
    log "Compressing LVM snapshot to $backup_file" "green"
    if sudo tar -czf "$backup_file" -C "$mountpoint" .; then
        log "LVM snapshot compressed successfully to $backup_file" "green"
    else
        log "Failed to compress LVM snapshot to $backup_file" "red"
        unlock_mongodb
        exit 1
    fi

    log "Unmounting LVM snapshot from $mountpoint" "green"
    if sudo umount "$mountpoint"; then
        sudo rmdir "$mountpoint"
        log "LVM snapshot unmounted successfully from $mountpoint" "green"
    else
        log "Failed to unmount LVM snapshot from $mountpoint" "red"
        exit 1
    fi
}

# Function to unlock the MongoDB database
unlock_mongodb() {
    log "Unlocking MongoDB database" "green"
    if ! mongo --username="$MONGODB_USER" --password="$MONGODB_PASS" --authenticationDatabase="admin" --port="$MONGODB_PORT" --eval "db.fsyncUnlock()" &>/dev/null; then
        log "Failed to unlock MongoDB database. Check MongoDB status and authentication." "red"
        exit 1
    fi
}

# Function to remove the LVM snapshot
remove_snapshot() {
    log "Removing LVM snapshot: $SNAPSHOT_NAME" "green"
    if ! sudo lvremove -f "/dev/$VOLUME_GROUP/$SNAPSHOT_NAME"; then
        log "Failed to remove LVM snapshot: $SNAPSHOT_NAME" "red"
        exit 1
    fi
}

# Main function
main() {
    # Create the backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    # Start the backup process
    log "Backup process started." "green"

    lock_mongodb
    record_oplog_position
    create_snapshot
    mount_snapshot
    backup_lvm_snapshot
    remove_snapshot
    unlock_mongodb

    log "Backup process completed." "green"
}

# Record the start time
start_time=$(date +%s)

# Call the main function
main

# Record the end time and calculate the overall process completion time
end_time=$(date +%s)
completion_time=$((end_time - start_time))

# Log the completion time in the HTML log file
log "Overall process completion time: $completion_time seconds" "green"
