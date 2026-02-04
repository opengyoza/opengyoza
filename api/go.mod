module github.com/opengyoza/opengyoza/api

go 1.24.0

toolchain go1.24.1

replace github.com/opengyoza/opengyoza/sdk => ../sdk

require (
	github.com/hashicorp/go-cleanhttp v0.5.1
	github.com/hashicorp/go-rootcerts v1.0.0
	github.com/hashicorp/go-uuid v1.0.1
	github.com/hashicorp/serf v0.8.2
	github.com/mitchellh/mapstructure v1.1.2
	github.com/opengyoza/opengyoza/sdk v0.3.0
	github.com/pascaldekloe/goe v0.0.0-20180627143212-57f6aae5913c
	github.com/stretchr/testify v1.3.0
)

require (
	github.com/armon/go-metrics v0.0.0-20180917152333-f0300d1749da // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/google/btree v0.0.0-20180813153112-4030bb1f1f0c // indirect
	github.com/hashicorp/errwrap v1.0.0 // indirect
	github.com/hashicorp/go-immutable-radix v1.0.0 // indirect
	github.com/hashicorp/go-msgpack v0.5.3 // indirect
	github.com/hashicorp/go-multierror v1.0.0 // indirect
	github.com/hashicorp/go-sockaddr v1.0.0 // indirect
	github.com/hashicorp/golang-lru v0.5.0 // indirect
	github.com/hashicorp/memberlist v0.1.3 // indirect
	github.com/miekg/dns v1.0.14 // indirect
	github.com/mitchellh/go-homedir v1.0.0 // indirect
	github.com/mitchellh/go-testing-interface v1.0.0 // indirect
	github.com/pkg/errors v0.8.1 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/sean-/seed v0.0.0-20170313163322-e2103e2c3529 // indirect
	golang.org/x/crypto v0.0.0-20181029021203-45a5f77698d3 // indirect
	golang.org/x/net v0.0.0-20181201002055-351d144fa1fc // indirect
	golang.org/x/sys v0.0.0-20181026203630-95b1ffbd15a5 // indirect
)
