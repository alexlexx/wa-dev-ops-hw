export MINIO_ENDPOINT=
export MINIO_ACCESS_KEY=
export MINIO_SECRET_KEY=

terraform init -backend-config="endpoint=$MINIO_ENDPOINT" -backend-config="access_key=$MINIO_ACCESS_KEY" -backend-config="secret_key=$MINIO_SECRET_KEY"
