package eu.jpereira.trainings.designpatterns.creational.abstractfactory.xml;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportBody;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportHeader;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportFooter;
import eu.jpereira.trainings.designpatterns.creational.abstractfactory.ReportElementsFactory;

public class XMLReportElementsFactory implements ReportElementsFactory {
    @Override
    public ReportBody createReportBody() {
        return new XMLReportBody();
    }

    @Override
    public ReportHeader createReportHeader() {
        return new XMLReportHeader();
    }

    @Override
    public ReportFooter createReportFooter() {
        return new XMLReportFooter();
    }
    
}
