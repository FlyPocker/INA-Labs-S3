package eu.jpereira.trainings.designpatterns.creational.builder;

import eu.jpereira.trainings.designpatterns.creational.builder.model.ReportBody;
import eu.jpereira.trainings.designpatterns.creational.builder.xml.XMLReportBody;

public class XMLReportBodyBuilder implements ReportBodyBuilder {

	private XMLReportBody reportBody = new XMLReportBody();

	@Override
	public ReportBodyBuilder setCustomerName(String customerName) {
		reportBody.putContent("<sale><customer><name>" + customerName + "</name>");
		return this;
	}

	@Override
	public ReportBodyBuilder setCustomerPhone(String phoneNumber) {
		reportBody.putContent("<phone>" + phoneNumber + "</phone></customer>");
		return this;
	}

	@Override
	public ReportBodyBuilder withItems() {
		reportBody.putContent("<items>");
		return this;
	}

	@Override
	public ReportBodyBuilder newItem(String name, int quantity, double price) {
		reportBody.putContent("<item><name>" + name + "</name><quantity>" + quantity + "</quantity><price>" + price + "</price></item>");
		return this;
	}

	@Override
	public ReportBody getReportBody() {
		reportBody.putContent("</items></sale>");
		return reportBody;
	}
}