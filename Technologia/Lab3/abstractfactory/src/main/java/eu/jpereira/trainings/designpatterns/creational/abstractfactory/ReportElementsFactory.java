package eu.jpereira.trainings.designpatterns.creational.abstractfactory;

public interface ReportElementsFactory {
    ReportBody createReportBody();
    ReportHeader createReportHeader();
    ReportFooter createReportFooter();
}
