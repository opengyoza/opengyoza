package authmethodlist

import (
	"os"
	"strings"
	"testing"

	"github.com/opengyoza/opengyoza/agent"
	"github.com/opengyoza/opengyoza/api"
	"github.com/opengyoza/opengyoza/logger"
	"github.com/opengyoza/opengyoza/sdk/testutil"
	"github.com/opengyoza/opengyoza/testrpc"
	"github.com/hashicorp/go-uuid"
	"github.com/mitchellh/cli"
	"github.com/stretchr/testify/require"

	// activate testing auth method
	_ "github.com/opengyoza/opengyoza/agent/consul/authmethod/testauth"
)

func TestAuthMethodListCommand_noTabs(t *testing.T) {
	t.Parallel()

	if strings.ContainsRune(New(cli.NewMockUi()).Help(), '\t') {
		t.Fatal("help has tabs")
	}
}

func TestAuthMethodListCommand(t *testing.T) {
	t.Parallel()

	testDir := testutil.TempDir(t, "acl")
	defer os.RemoveAll(testDir)

	a := agent.NewTestAgent(t, t.Name(), `
	primary_datacenter = "dc1"
	acl {
		enabled = true
		tokens {
			master = "root"
		}
	}`)

	a.Agent.LogWriter = logger.NewLogWriter(512)

	defer a.Shutdown()
	testrpc.WaitForLeader(t, a.RPC, "dc1")

	t.Run("found none", func(t *testing.T) {
		ui := cli.NewMockUi()
		cmd := New(ui)

		args := []string{
			"-http-addr=" + a.HTTPAddr(),
			"-token=root",
		}

		code := cmd.Run(args)
		require.Equal(t, code, 0)
		require.Empty(t, ui.ErrorWriter.String())
		require.Empty(t, ui.OutputWriter.String())
	})

	client := a.Client()

	createAuthMethod := func(t *testing.T) string {
		id, err := uuid.GenerateUUID()
		require.NoError(t, err)

		methodName := "test-" + id

		_, _, err = client.ACL().AuthMethodCreate(
			&api.ACLAuthMethod{
				Name:        methodName,
				Type:        "testing",
				Description: "test",
			},
			&api.WriteOptions{Token: "root"},
		)
		require.NoError(t, err)

		return methodName
	}

	var methodNames []string
	for i := 0; i < 5; i++ {
		methodName := createAuthMethod(t)
		methodNames = append(methodNames, methodName)
	}

	t.Run("found some", func(t *testing.T) {
		ui := cli.NewMockUi()
		cmd := New(ui)

		args := []string{
			"-http-addr=" + a.HTTPAddr(),
			"-token=root",
		}

		code := cmd.Run(args)
		require.Equal(t, code, 0)
		require.Empty(t, ui.ErrorWriter.String())
		output := ui.OutputWriter.String()

		for _, methodName := range methodNames {
			require.Contains(t, output, methodName)
		}
	})
}
