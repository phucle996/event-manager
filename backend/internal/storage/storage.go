package storage

import (
	"context"
	"io"
)

// ObjectStorage defines the contract for uploading binary objects and returning
// an accessible URL.
type ObjectStorage interface {
	Upload(ctx context.Context, objectName string, reader io.Reader, size int64, contentType string) (string, error)
}
