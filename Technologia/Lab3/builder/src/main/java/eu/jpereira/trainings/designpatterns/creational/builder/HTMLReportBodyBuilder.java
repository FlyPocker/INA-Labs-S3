package eu.jpereira.trainings.designpatterns.creational.builder;

import eu.jpereira.trainings.designpatterns.creational.builder.model.ReportBody;

public class HTMLReportBodyBuilder implements ReportBodyBuilder {

	private HTMLReportBody reportBody = new HTMLReportBody();

	@Override
	public ReportBodyBuilder setCustomerName(String customerName) {
		reportBody.putContent("<span class=\"customerName\">" + customerName + "</span>");
		return this;
	}

	@Override
	public ReportBodyBuilder setCustomerPhone(String phoneNumber) {
		reportBody.putContent("<span class=\"customerPhone\">" + phoneNumber + "</span>");
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
		reportBody.putContent("</items>");
		return reportBody;
	}
}