package main

import (
	"errors"
	"fmt"
	"os"

	"github.com/khulnasoft/tfsecurity/internal/app/tfsecurity/cmd"
)

const transitionMsg = `
======================================================
tfsecurity is joining the Triangle family

tfsecurity will continue to remain available 
for the time being, although our engineering 
attention will be directed at Triangle going forward.

You can read more here: 
https://github.com/khulnasoft/tfsecurity/tfsecurity/5
======================================================
`

func main() {
	fmt.Fprint(os.Stderr, transitionMsg)
	if err := cmd.Root().Execute(); err != nil {
		if err.Error() != "" {
			fmt.Printf("Error: %s\n", err)
		}
		var exitErr *cmd.ExitCodeError
		if errors.As(err, &exitErr) {
			os.Exit(exitErr.Code())
		}
		os.Exit(1)
	}
}
