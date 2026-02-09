package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/mitchellh/cli"
	"github.com/opengyoza/opengyoza/command"
	"github.com/opengyoza/opengyoza/lib"
	_ "github.com/opengyoza/opengyoza/service_os"
)

func init() {
	lib.SeedMathRand()
}

func main() {
	os.Exit(realMain())
}

func realMain() int {
	log.SetOutput(ioutil.Discard)

	args := os.Args[1:]
	for _, arg := range args {
		if arg == "--" {
			break
		}

		if arg == "-v" || arg == "--version" {
			args = []string{"version"}
			break
		}
	}

	ui := &cli.BasicUi{Writer: os.Stdout, ErrorWriter: os.Stderr}
	cmds := command.Map(ui)
	var names []string
	for c := range cmds {
		names = append(names, c)
	}

	cli := &cli.CLI{
		Args:         args,
		Commands:     cmds,
		Autocomplete: true,
		Name:         "gyoza",
		HelpFunc:     cli.FilteredHelpFunc(names, cli.BasicHelpFunc("gyoza")),
	}

	exitCode, err := cli.Run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error executing CLI: %s\n", err.Error())
		return 1
	}

	return exitCode
}
