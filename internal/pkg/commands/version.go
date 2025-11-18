package commands

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/khulnasoft/tfsecurity/version"
)

func newVersionCommand() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Show the version of tfsecurity",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Printf("tfsecurity version %s\n", version.Version)
			fmt.Printf("Built with %s\n", version.GoVersion)
			fmt.Printf("Built on %s\n", version.BuildDate)
		},
	}
}
