package env

import (
	"fmt"
)

var (
	Branch    string
	BuildTime string
	Version   string
)

func PrintVersion() {
	fmt.Println("Build Info:")
	fmt.Println(fmt.Sprintf("\tBranch:\t\t%s", Branch))
	fmt.Println(fmt.Sprintf("\tBuild Time:\t%s", BuildTime))
	fmt.Println(fmt.Sprintf("\tVersion:\t%s", Version))
}
