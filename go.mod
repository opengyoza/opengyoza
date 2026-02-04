module github.com/opengyoza/opengyoza

go 1.24.0
toolchain go1.24.0

replace github.com/opengyoza/opengyoza/api => ./api

replace github.com/opengyoza/opengyoza/sdk => ./sdk

require (
	github.com/NYTimes/gziphandler v1.0.1
	github.com/armon/circbuf v0.0.0-20150827004946-bbbad097214e
	github.com/armon/go-metrics v0.0.0-20190430140413-ec5e00d3c878
	github.com/armon/go-radix v1.0.0
	github.com/coredns/coredns v1.1.2
	github.com/docker/go-connections v0.3.0
	github.com/elazarl/go-bindata-assetfs v0.0.0-20160803192304-e1a2a7ec64b0
	github.com/envoyproxy/go-control-plane v0.8.0
	github.com/gogo/googleapis v1.1.0
	github.com/gogo/protobuf v1.2.1
	github.com/golang/protobuf v1.3.1
	github.com/google/gofuzz v0.0.0-20170612174753-24818f796faf
	github.com/hashicorp/go-bexpr v0.1.2
	github.com/hashicorp/go-checkpoint v0.0.0-20171009173528-1545e56e46de
	github.com/hashicorp/go-cleanhttp v0.5.1
	github.com/hashicorp/go-connlimit v0.1.0
	github.com/hashicorp/go-discover v0.0.0-20190403160810-22221edb15cd
	github.com/hashicorp/go-hclog v0.9.2
	github.com/hashicorp/go-memdb v0.0.0-20180223233045-1289e7fffe71
	github.com/hashicorp/go-msgpack v0.5.5
	github.com/hashicorp/go-multierror v1.0.0
	github.com/hashicorp/go-plugin v1.0.1
	github.com/hashicorp/go-raftchunking v0.6.1
	github.com/hashicorp/go-sockaddr v1.0.2
	github.com/hashicorp/go-syslog v1.0.0
	github.com/hashicorp/go-uuid v1.0.1
	github.com/hashicorp/go-version v1.1.0
	github.com/hashicorp/golang-lru v0.5.1
	github.com/hashicorp/hcl v1.0.0
	github.com/hashicorp/hil v0.0.0-20160711231837-1e86c6b523c5
	github.com/hashicorp/logutils v1.0.0
	github.com/hashicorp/memberlist v0.1.5
	github.com/hashicorp/net-rpc-msgpackrpc v0.0.0-20151116020338-a14192a58a69
	github.com/hashicorp/raft v1.1.1
	github.com/hashicorp/raft-boltdb v0.0.0-20171010151810-6e5ba93211ea
	github.com/hashicorp/serf v0.8.5
	github.com/hashicorp/vault/api v1.0.4
	github.com/hashicorp/yamux v0.0.0-20181012175058-2f1d1f20f75d
	github.com/imdario/mergo v0.3.6
	github.com/kr/text v0.1.0
	github.com/miekg/dns v1.1.26
	github.com/mitchellh/cli v1.0.0
	github.com/mitchellh/copystructure v1.0.0
	github.com/mitchellh/go-testing-interface v1.0.0
	github.com/mitchellh/hashstructure v0.0.0-20170609045927-2bca23e0e452
	github.com/mitchellh/mapstructure v1.1.2
	github.com/mitchellh/reflectwalk v1.0.1
	github.com/opengyoza/opengyoza/api v1.3.0
	github.com/opengyoza/opengyoza/sdk v0.3.0
	github.com/pascaldekloe/goe v0.1.0
	github.com/pkg/errors v0.8.1
	github.com/prometheus/client_golang v0.9.2
	github.com/ryanuber/columnize v2.1.0+incompatible
	github.com/shirou/gopsutil/v3 v3.24.5
	github.com/stretchr/testify v1.9.0
	golang.org/x/crypto v0.47.0
	golang.org/x/net v0.49.0
	golang.org/x/sync v0.19.0
	golang.org/x/sys v0.40.0
	golang.org/x/time v0.0.0-20190308202827-9d24e82272b4
	google.golang.org/grpc v1.23.0
	gopkg.in/square/go-jose.v2 v2.3.1
	k8s.io/api v0.0.0-20190325185214-7544f9db76f6
	k8s.io/apimachinery v0.0.0-20190223001710-c182ff3b9841
	k8s.io/client-go v8.0.0+incompatible
)

require (
	cloud.google.com/go v0.26.0 // indirect
	github.com/Azure/azure-sdk-for-go v16.0.0+incompatible // indirect
	github.com/Azure/go-autorest v10.15.3+incompatible // indirect
	github.com/DataDog/datadog-go v2.2.0+incompatible // indirect
	github.com/Microsoft/go-winio v0.4.3 // indirect
	github.com/aws/aws-sdk-go v1.15.24 // indirect
	github.com/beorn7/perks v0.0.0-20180321164747-3a771d992973 // indirect
	github.com/bgentry/speakeasy v0.1.0 // indirect
	github.com/boltdb/bolt v1.3.1 // indirect
	github.com/circonus-labs/circonus-gometrics v2.3.1+incompatible // indirect
	github.com/circonus-labs/circonusllhist v0.1.3 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/denverdino/aliyungo v0.0.0-20170926055100-d3308649c661 // indirect
	github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect
	github.com/digitalocean/godo v1.10.0 // indirect
	github.com/envoyproxy/protoc-gen-validate v0.0.14 // indirect
	github.com/fatih/color v1.7.0 // indirect
	github.com/ghodss/yaml v1.0.0 // indirect
	github.com/go-ini/ini v1.25.4 // indirect
	github.com/go-ole/go-ole v1.2.6 // indirect
	github.com/golang/glog v0.0.0-20160126235308-23def4e6c14b // indirect
	github.com/golang/snappy v0.0.1 // indirect
	github.com/google/btree v0.0.0-20180813153112-4030bb1f1f0c // indirect
	github.com/google/go-querystring v0.0.0-20170111101155-53e6ce116135 // indirect
	github.com/googleapis/gnostic v0.2.0 // indirect
	github.com/gophercloud/gophercloud v0.0.0-20180828235145-f29afc2cceca // indirect
	github.com/gregjones/httpcache v0.0.0-20180305231024-9cad4c3443a7 // indirect
	github.com/hashicorp/errwrap v1.0.0 // indirect
	github.com/hashicorp/go-immutable-radix v1.0.0 // indirect
	github.com/hashicorp/go-retryablehttp v0.5.4 // indirect
	github.com/hashicorp/go-rootcerts v1.0.1 // indirect
	github.com/hashicorp/mdns v1.0.1 // indirect
	github.com/hashicorp/vault/sdk v0.1.13 // indirect
	github.com/hashicorp/vic v1.5.1-0.20190403131502-bbfe86ec9443 // indirect
	github.com/jmespath/go-jmespath v0.0.0-20160202185014-0b12d6b521d8 // indirect
	github.com/joyent/triton-go v0.0.0-20180628001255-830d2b111e62 // indirect
	github.com/json-iterator/go v1.1.5 // indirect
	github.com/lufia/plan9stats v0.0.0-20211012122336-39d0f177ccd0 // indirect
	github.com/mattn/go-colorable v0.0.9 // indirect
	github.com/mattn/go-isatty v0.0.3 // indirect
	github.com/matttproud/golang_protobuf_extensions v1.0.1 // indirect
	github.com/mitchellh/go-homedir v1.1.0 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.1 // indirect
	github.com/nicolai86/scaleway-sdk v1.10.2-0.20180628010248-798f60e20bb2 // indirect
	github.com/oklog/run v1.0.0 // indirect
	github.com/packethost/packngo v0.1.1-0.20180711074735-b9cb5096f54c // indirect
	github.com/peterbourgon/diskv v2.0.1+incompatible // indirect
	github.com/pierrec/lz4 v2.0.5+incompatible // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/posener/complete v1.1.1 // indirect
	github.com/power-devops/perfstat v0.0.0-20210106213030-5aafc221ea8c // indirect
	github.com/prometheus/client_model v0.0.0-20180712105110-5c3871d89910 // indirect
	github.com/prometheus/common v0.0.0-20181126121408-4724e9255275 // indirect
	github.com/prometheus/procfs v0.0.0-20181204211112-1dc9a6cbc91a // indirect
	github.com/renier/xmlrpc v0.0.0-20170708154548-ce4a1a486c03 // indirect
	github.com/ryanuber/go-glob v1.0.0 // indirect
	github.com/sean-/seed v0.0.0-20170313163322-e2103e2c3529 // indirect
	github.com/shoenig/go-m1cpu v0.1.6 // indirect
	github.com/sirupsen/logrus v1.0.6 // indirect
	github.com/softlayer/softlayer-go v0.0.0-20180806151055-260589d94c7d // indirect
	github.com/spf13/pflag v1.0.3 // indirect
	github.com/stretchr/objx v0.5.2 // indirect
	github.com/tklauser/go-sysconf v0.3.12 // indirect
	github.com/tklauser/numcpus v0.6.1 // indirect
	github.com/tv42/httpunix v0.0.0-20150427012821-b75d8614f926 // indirect
	github.com/vmware/govmomi v0.18.0 // indirect
	github.com/yusufpapurcu/wmi v1.2.4 // indirect
	golang.org/x/oauth2 v0.0.0-20180821212333-d2e6202438be // indirect
	golang.org/x/term v0.39.0 // indirect
	golang.org/x/text v0.33.0 // indirect
	google.golang.org/api v0.0.0-20180829000535-087779f1d2c9 // indirect
	google.golang.org/appengine v1.4.0 // indirect
	google.golang.org/genproto v0.0.0-20190404172233-64821d5d2107 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/yaml.v2 v2.2.2 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
