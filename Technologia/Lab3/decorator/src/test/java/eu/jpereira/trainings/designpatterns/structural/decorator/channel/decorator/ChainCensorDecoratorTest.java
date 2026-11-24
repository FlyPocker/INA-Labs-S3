package eu.jpereira.trainings.designpatterns.structural.decorator.channel.decorator;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannel;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannelBuilder;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannelProperties;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannelPropertyKey;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.spy.TestSpySocialChannel;

public class ChainCensorDecoratorTest extends AbstractSocialChanneldDecoratorTest {

	@Test
	public void testChainThreeDecoratorsWithBuilder() {
		SocialChannelBuilder builder = createTestSpySocialChannelBuilder();
		SocialChannelProperties props = new SocialChannelProperties()
				.putProperty(SocialChannelPropertyKey.NAME, TestSpySocialChannel.NAME);

		SocialChannel channel = builder
				.with(new WordCensor("Microsoft"))
				.with(new MessageTruncator(15))
				.with(new URLAppender("http://jpereira.eu"))
				.getDecoratedChannel(props);

		channel.deliverMessage("Microsoft Windows is great!!");

		TestSpySocialChannel spyChannel = (TestSpySocialChannel) builder.buildChannel(props);
		assertEquals("### Windows ... http://jpereira.eu", spyChannel.lastMessagePublished());
	}

	@Test
	public void testChainThreeDecoratorsWithoutBuilder() {
		SocialChannel channel = new TestSpySocialChannel();
		SocialChannel urlAppender = new URLAppender("http://jpereira.eu", channel);
		SocialChannel truncator = new MessageTruncator(15, urlAppender);
		SocialChannel censor = new WordCensor("Microsoft", truncator);

		censor.deliverMessage("Microsoft Windows is great!!");

		TestSpySocialChannel spy = (TestSpySocialChannel) channel;
		assertEquals("### Windows ... http://jpereira.eu", spy.lastMessagePublished());
	}
}