package storage

import (
    "context"
    "fmt"
    "io"
    "os"
    "strings"
    "time"

    "github.com/minio/minio-go/v7"
    "github.com/minio/minio-go/v7/pkg/credentials"
)

// MinioStorage implements ObjectStorage backed by a MinIO bucket.
type MinioStorage struct {
	client       *minio.Client
	bucket       string
	publicBase   string
}

// NewMinioStorageFromEnv builds a MinioStorage using environment variables:
//   MINIO_ENDPOINT      - host:port of the MinIO server (required)
//   MINIO_ACCESS_KEY    - access key (required)
//   MINIO_SECRET_KEY    - secret key (required)
//   MINIO_BUCKET        - target bucket (default: events-manager)
//   MINIO_USE_SSL       - "true" to enable TLS (optional)
//   MINIO_PUBLIC_URL    - base URL used to construct public object URLs (optional)
func NewMinioStorageFromEnv() (*MinioStorage, error) {
	endpoint := strings.TrimSpace(os.Getenv("MINIO_ENDPOINT"))
	if endpoint == "" {
		return nil, fmt.Errorf("MINIO_ENDPOINT is required")
	}

	accessKey := strings.TrimSpace(os.Getenv("MINIO_ACCESS_KEY"))
	if accessKey == "" {
		return nil, fmt.Errorf("MINIO_ACCESS_KEY is required")
	}

	secretKey := strings.TrimSpace(os.Getenv("MINIO_SECRET_KEY"))
	if secretKey == "" {
		return nil, fmt.Errorf("MINIO_SECRET_KEY is required")
	}

	bucket := strings.TrimSpace(os.Getenv("MINIO_BUCKET"))
	if bucket == "" {
		bucket = "events-manager"
	}

	useSSL := strings.EqualFold(os.Getenv("MINIO_USE_SSL"), "true")

	client, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create minio client: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	exists, err := client.BucketExists(ctx, bucket)
	if err != nil {
		return nil, fmt.Errorf("failed to check bucket %s: %w", bucket, err)
	}
	if !exists {
		if err := client.MakeBucket(ctx, bucket, minio.MakeBucketOptions{}); err != nil {
			return nil, fmt.Errorf("failed to create bucket %s: %w", bucket, err)
		}
	}

	publicBase := strings.TrimSpace(os.Getenv("MINIO_PUBLIC_URL"))
	if publicBase == "" {
		scheme := "http"
		if useSSL {
			scheme = "https"
		}
		publicBase = fmt.Sprintf("%s://%s", scheme, endpoint)
	}
	publicBase = strings.TrimRight(publicBase, "/")

	return &MinioStorage{
		client:     client,
		bucket:     bucket,
		publicBase: publicBase,
	}, nil
}

// Upload saves the reader content as objectName and returns its public URL.
func (m *MinioStorage) Upload(ctx context.Context, objectName string, reader io.Reader, size int64, contentType string) (string, error) {
	if ctx == nil {
		ctx = context.Background()
	}

	opts := minio.PutObjectOptions{
		ContentType:        contentType,
		DisableMultipart:   size <= 0,
	}

	if _, err := m.client.PutObject(ctx, m.bucket, objectName, reader, size, opts); err != nil {
		return "", fmt.Errorf("upload object %s failed: %w", objectName, err)
	}

	return fmt.Sprintf("%s/%s/%s", m.publicBase, m.bucket, strings.TrimLeft(objectName, "/")), nil
}
