package eu.jpereira.trainings.designpatterns.creational.builder;

import eu.jpereira.trainings.designpatterns.creational.builder.json.JSONReportBody;
import eu.jpereira.trainings.designpatterns.creational.builder.model.ReportBody;

public class JSONReportBodyBuilder implements ReportBodyBuilder {
    private JSONReportBody reportBody = new JSONReportBody();
    private boolean firstItem = true;

    @Override
	public ReportBodyBuilder setCustomerName(String customerName) {
		reportBody.addContent("sale:{customer:{name:\"" + customerName + "\"");
		return this;
	}

	@Override
	public ReportBodyBuilder setCustomerPhone(String phoneNumber) {
		reportBody.addContent(",phone:\"" + phoneNumber + "\"}");
		return this;
	}

	@Override
	public ReportBodyBuilder withItems() {
		reportBody.addContent(",items:[");
		return this;
	}

	@Override
	public ReportBodyBuilder newItem(String name, int quantity, double price) {
		if (!firstItem) {
			reportBody.addContent(",");
		}
		firstItem = false;
		reportBody.addContent("{name:\"" + name + "\",quantity:" + quantity + ",price:" + price + "}");
		return this;
	}

	@Override
	public ReportBody getReportBody() {
		reportBody.addContent("]}");
		return reportBody;
	}
}
