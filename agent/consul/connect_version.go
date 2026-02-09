package consul

import "github.com/hashicorp/go-version"

// minMultiDCConnectVersion is the minimum version required to support
// multi-datacenter Connect features.
var minMultiDCConnectVersion = version.Must(version.NewVersion("1.6.0"))
