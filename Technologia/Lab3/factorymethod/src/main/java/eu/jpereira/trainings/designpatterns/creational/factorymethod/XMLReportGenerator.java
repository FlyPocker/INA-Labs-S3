package eu.jpereira.trainings.designpatterns.creational.factorymethod;

public class XMLReportGenerator extends ReportGenerator {
    @Override
    protected Report instanceReport() {
        return new XMLReport();
    }
}
