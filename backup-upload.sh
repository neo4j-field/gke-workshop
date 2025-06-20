#!/usr/bin/env bash
set -euo pipefail

# Configuration
CONTAINER_NAME="d4j"
DATABASE_NAME="neo4j"
CONTAINER_BACKUP_DIR="/backups"
LOCAL_BACKUP_DIR="$(pwd)/backups"
GCS_BUCKET="gs://neo4j-workshop-eu"
GCS_LOCATION="europe-west1"      # Bucket region (Europe)
FILENAME_PREFIX="jqassistant"    # Prefix for dump filename

# Ensure local backup directory exists
mkdir -p "$LOCAL_BACKUP_DIR"

# Generate timestamp for filename
ts="$(date +%Y%m%d-%H%M%S)"
LOCAL_DUMP_NAME="${FILENAME_PREFIX}-${ts}.dump"  # Single dump filename on host

# 1. Check if GCS bucket exists; if not, create it and set public-read default
if ! gsutil ls "$GCS_BUCKET" >/dev/null 2>&1; then
  echo "[*] Bucket $GCS_BUCKET does not exist. Creating in region $GCS_LOCATION..."
  gsutil mb -l "$GCS_LOCATION" "$GCS_BUCKET"
  echo "[*] Setting default object ACL to public-read..."
  gsutil defacl set public-read "$GCS_BUCKET"
else
  echo "[*] Bucket $GCS_BUCKET exists."
fi

# 2. Prepare container backup directory (delete and recreate)
echo "[*] Preparing backup directory in container $CONTAINER_NAME by deleting and recreating..."
docker exec "$CONTAINER_NAME" bash -c "rm -rf $CONTAINER_BACKUP_DIR && mkdir -p $CONTAINER_BACKUP_DIR"

# 3. Dump the database inside the container to the directory
echo "[*] Dumping database '$DATABASE_NAME' into container path $CONTAINER_BACKUP_DIR..."
docker exec "$CONTAINER_NAME" \
  neo4j-admin database dump "$DATABASE_NAME" \
    --to-path="$CONTAINER_BACKUP_DIR"

# 4. Copy (and overwrite) the dump file from the container to the host
echo "[*] Copying dump file to host directory $LOCAL_BACKUP_DIR as $LOCAL_DUMP_NAME..."
docker cp "$CONTAINER_NAME":"$CONTAINER_BACKUP_DIR/$DATABASE_NAME.dump" "$LOCAL_BACKUP_DIR/$LOCAL_DUMP_NAME"

# 5. Check if the dump file exists in bucket; delete if so
echo "[*] Checking for existing backup file in bucket..."
if gsutil -q stat "$GCS_BUCKET/$LOCAL_DUMP_NAME"; then
  echo "[*] Found existing file $LOCAL_DUMP_NAME in bucket. Deleting..."
  gsutil rm "$GCS_BUCKET/$LOCAL_DUMP_NAME"
fi

# 6. Upload the dump file to the root of the bucket
echo "[*] Uploading $LOCAL_BACKUP_DIR/$LOCAL_DUMP_NAME to $GCS_BUCKET/"
gsutil cp "$LOCAL_BACKUP_DIR/$LOCAL_DUMP_NAME" "$GCS_BUCKET/"

# 7. Ensure the uploaded object is publicly readable
echo "[*] Setting public-read ACL on uploaded file..."
gsutil acl ch -u AllUsers:R "$GCS_BUCKET/$LOCAL_DUMP_NAME"

# 8. Output the public URL of the file
echo "Backup completed and available at: https://storage.googleapis.com/${GCS_BUCKET#gs://}/$LOCAL_DUMP_NAME"
