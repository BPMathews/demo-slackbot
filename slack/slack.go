package slack

import (
	"fmt"
	"strings"

	"bitbucket.org/BPMathews/demo-slackbot/env"
	"github.com/nlopes/slack"
)

// CreateSlackClient sets up the slack RTM (real-timemessaging) client library,
// initiating the socket connection and returning the client
func CreateSlackClient(apiKey string) *slack.RTM {
	api := slack.New(apiKey)

	rtm := api.NewRTM()
	go rtm.ManageConnection()
	return rtm
}

func Start(token string) {
	api := CreateSlackClient(token)

	rtm := api.NewRTM()
	go rtm.ManageConnection()

	for msg := range rtm.IncomingEvents {
		switch ev := msg.Data.(type) {
		case *slack.MessageEvent:
			botTagString := fmt.Sprintf("<@%s>", rtm.GetInfo().User.ID)
			if !strings.Contains(ev.Msg.Text, botTagString) {
				continue
			}

			apiOutgoing := slack.PostMessageParameters{
				Username: env.SlackBotSettings.Name,
				IconURL:  env.SlackBotSettings.ImageURL,
			}
			api.PostMessage(ev.Channel, "I'm a Robot!", apiOutgoing)

			//outgoingMessage := rtm.NewOutgoingMessage("Hello!", ev.Channel)
			//rtm.SendMessage(outgoingMessage)
		}
	}
}
