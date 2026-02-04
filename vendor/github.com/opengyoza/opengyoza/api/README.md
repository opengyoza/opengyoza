OpenGyoza API client
====================

This package provides the `api` package which attempts to
provide programmatic access to the full OpenGyoza API.

Currently, all of the OpenGyoza APIs included in the 1.6.4 base are supported.

Documentation
=============

The full documentation is available on [pkg.go.dev](https://pkg.go.dev/github.com/opengyoza/opengyoza/api)

Usage
=====

Below is an example of using the OpenGyoza client:

```go
package main

import "github.com/opengyoza/opengyoza/api"
import "fmt"

func main() {
	// Get a new client
	client, err := api.NewClient(api.DefaultConfig())
	if err != nil {
		panic(err)
	}

	// Get a handle to the KV API
	kv := client.KV()

	// PUT a new KV pair
	p := &api.KVPair{Key: "REDIS_MAXCLIENTS", Value: []byte("1000")}
	_, err = kv.Put(p, nil)
	if err != nil {
		panic(err)
	}

	// Lookup the pair
	pair, _, err := kv.Get("REDIS_MAXCLIENTS", nil)
	if err != nil {
		panic(err)
	}
	fmt.Printf("KV: %v %s\n", pair.Key, pair.Value)
}
```

To run this example, start an OpenGyoza agent:

```bash
gyoza agent -dev
```

Copy the code above into a file such as `main.go`.

Install and run. You'll see a key (`REDIS_MAXCLIENTS`) and value (`1000`) printed.

```bash
$ go get
$ go run main.go
KV: REDIS_MAXCLIENTS 1000
```

After running the code, you can also view the values in the OpenGyoza UI on your local machine at http://localhost:8500/ui/dc1/kv
