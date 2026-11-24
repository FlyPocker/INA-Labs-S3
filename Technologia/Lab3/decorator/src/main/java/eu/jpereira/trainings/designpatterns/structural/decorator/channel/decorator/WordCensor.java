package eu.jpereira.trainings.designpatterns.structural.decorator.channel.decorator;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannel;

public class WordCensor extends SocialChannelDecorator {

    private String wordToCensor;
    public WordCensor(String wordToCensor) {
        this.wordToCensor = wordToCensor;
    }

    public WordCensor(String wordToCensor, SocialChannel decoratedChannel) {
        this.wordToCensor = wordToCensor;
        this.delegate = decoratedChannel;
    }

    @Override
    public void deliverMessage(String message) {
        String censoredMessage = message.replaceAll(this.wordToCensor, "###");
        if (delegate != null) {
            delegate.deliverMessage(censoredMessage);
        }
    }
}
