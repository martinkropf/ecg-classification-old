package at.ac.ait.imagemanagement.testing;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import at.ac.ait.ecg.controller.BaseController;

public class SimpleControllerTests {

	@Test
	public void test() {
		BaseController controller = new BaseController();
		assertEquals("Hello world!", controller.specific("test"));
	}
}
