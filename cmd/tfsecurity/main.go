package main

import (
	"errors"
	"fmt"
	"os"

	"github.com/khulnasoft/tfsecurity/internal/pkg/commands"
)

const transitionMsg = `
======================================================
tfsecurity is joining the Trivy family

tfsecurity will continue to remain available 
for the time being, although our engineering 
attention will be directed at Trivy going forward.

You can read more here: 
https://github.com/khulnasoft/tfsecurity/discussions/5
======================================================
`

func main() {
	fmt.Fprint(os.Stderr, transitionMsg)
	if err := commands.NewRootCommand().Execute(); err != nil {
		if err.Error() != "" {
			fmt.Printf("Error: %s\n", err)
		}
		os.Exit(1)
	}
}
