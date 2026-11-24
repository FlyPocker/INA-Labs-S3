package eu.jpereira.trainings.designpatterns.creational.abstractfactory.json;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportBody;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportHeader;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportFooter;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportElementsFactory;

public class JSONReportElementsFactory implements ReportElementsFactory {
    @Override
    public ReportBody createReportBody() {
        return new JSONReportBody();
    }

    @Override
    public ReportHeader createReportHeader() {
        return new JSONReportHeader();
    }

    @Override
    public ReportFooter createReportFooter() {
        return new JSONReportFooter();
    }
}
