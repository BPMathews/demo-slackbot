package env

import (
	"fmt"
)

var (
	branch    string
	buildTime string
	version   string
)

func printVersion() {
	fmt.Println("Build Info:")
	fmt.Println(fmt.Sprintf("\tBranch:\t\t%s", branch))
	fmt.Println(fmt.Sprintf("\tBuild Time:\t%s", buildTime))
	fmt.Println(fmt.Sprintf("\tVersion:\t%s", version))
}

func Version() string {
	return fmt.Sprintf("*Version:* %s\n*Build Time:* %s\n*Branch:* %s", version, buildTime, branch)
}
