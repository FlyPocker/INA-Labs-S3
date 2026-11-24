package eu.jpereira.trainings.designpatterns.creational.prototype;

import static org.junit.Assert.*;

import java.util.List;
import java.util.Properties;

import org.junit.Test;

import eu.jpereira.trainings.designpatterns.creational.prototype.model.AbstractVehiclePart;
import eu.jpereira.trainings.designpatterns.creational.prototype.model.Shell;
import eu.jpereira.trainings.designpatterns.creational.prototype.model.Tire;
import eu.jpereira.trainings.designpatterns.creational.prototype.model.Vehicle;
import eu.jpereira.trainings.designpatterns.creational.prototype.model.VehiclePartEnumeration;
import eu.jpereira.trainings.designpatterns.creational.prototype.model.VehiclePartPropertiesEnumeration;
import eu.jpereira.trainings.designpatterns.creational.prototype.model.Window;

public class VehicleCloneTest {

	@Test
	public void testCloneVehicleDeepCopy() throws Exception {
		Client client = new Client();

		Properties tiresProps = new Properties();
		tiresProps.put(VehiclePartPropertiesEnumeration.SIZE, 10);

		Properties shellProps = new Properties();
		shellProps.put(VehiclePartPropertiesEnumeration.COLOR, "blue");

		Properties windowProps = new Properties();
		windowProps.put(VehiclePartPropertiesEnumeration.WIDTH, 20);

		Vehicle original = client.vehicleBuilder()
				.createVehicle()
				.with(new Tire(tiresProps)).times(4)
				.with(new Window(windowProps)).times(2)
				.with(new Shell(shellProps)).times(1)
				.packIt();

		Vehicle cloned = (Vehicle) original.clone();

		// 1. Inne instancje pojazdu, ta sama liczba części
		assertNotSame(original, cloned);
		assertEquals(original.countParts(), cloned.countParts());

		// 2. Głęboka kopia części
		List<VehiclePart> originalShells = original.getParts(VehiclePartEnumeration.SHELL);
		List<VehiclePart> clonedShells = cloned.getParts(VehiclePartEnumeration.SHELL);
		assertEquals(1, clonedShells.size());
		assertNotSame(originalShells.get(0), clonedShells.get(0));

		// 3. Głęboka kopia Properties
		Properties originalShellProps = ((AbstractVehiclePart) originalShells.get(0)).getPartProperties();
		Properties clonedShellProps = ((AbstractVehiclePart) clonedShells.get(0)).getPartProperties();
		assertNotSame(originalShellProps, clonedShellProps);
		assertEquals("blue", clonedShellProps.get(VehiclePartPropertiesEnumeration.COLOR));

		clonedShellProps.put(VehiclePartPropertiesEnumeration.COLOR, "red");
		assertEquals("blue", originalShellProps.get(VehiclePartPropertiesEnumeration.COLOR));
	}
}