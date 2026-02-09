package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"runtime"
	"syscall"
)

const (
	shimSilentEnv       = "GYOZA_CONSUL_SHIM_SILENT"
	legacyShimSilentEnv = "CONSUL_SHIM_SILENT"
)

func main() {
	gyozaPath, err := resolveGyoza()
	if err != nil {
		fmt.Fprintf(os.Stderr, "consul shim error: %v\n", err)
		os.Exit(1)
	}

	if os.Getenv(shimSilentEnv) == "" && os.Getenv(legacyShimSilentEnv) == "" {
		fmt.Fprintln(os.Stderr, "WARNING: 'consul' is a compatibility shim for 'gyoza'. Prefer 'gyoza' directly.")
		fmt.Fprintln(os.Stderr, "Set GYOZA_CONSUL_SHIM_SILENT=1 to disable this warning.")
		fmt.Fprintln(os.Stderr, "")
	}

	exitCode := runGyoza(gyozaPath, os.Args[1:])
	os.Exit(exitCode)
}

func resolveGyoza() (string, error) {
	exe, err := os.Executable()
	if err == nil {
		dir := filepath.Dir(exe)
		name := "gyoza"
		if runtime.GOOS == "windows" {
			name += ".exe"
		}
		candidate := filepath.Join(dir, name)
		if info, statErr := os.Stat(candidate); statErr == nil && !info.IsDir() {
			return candidate, nil
		}
	}

	if path, lookErr := exec.LookPath("gyoza"); lookErr == nil {
		return path, nil
	}

	return "", errors.New("gyoza binary not found in the current directory or PATH")
}

func runGyoza(path string, args []string) int {
	cmd := exec.Command(path, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		fmt.Fprintf(os.Stderr, "consul shim failed: %v\n", err)
		return 1
	}

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	defer signal.Stop(sigCh)

	done := make(chan error, 1)
	go func() {
		done <- cmd.Wait()
	}()

	for {
		select {
		case sig := <-sigCh:
			if cmd.Process != nil {
				_ = cmd.Process.Signal(sig)
			}
		case err := <-done:
			return exitCodeFrom(err)
		}
	}
}

func exitCodeFrom(err error) int {
	if err == nil {
		return 0
	}
	if exitErr, ok := err.(*exec.ExitError); ok {
		if status, ok := exitErr.Sys().(interface{ ExitStatus() int }); ok {
			return status.ExitStatus()
		}
	}

	fmt.Fprintf(os.Stderr, "consul shim failed: %v\n", err)
	return 1
}
