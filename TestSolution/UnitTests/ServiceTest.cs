using System;
using BusinessLayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UnitTests
{
    [TestClass]
    public class ServiceTest
    {
        private IService _service;
        [TestInitialize]
        public void Setup()
        {
            _service = new Service();
        }
        [TestMethod]
        public void ShouldReturnTrue()
        {
            //Arrange
            const bool expectedResult = true;
            //Act
            var result = _service.Counter();
            //Assert
            Assert.AreEqual(expectedResult, result);
        }
    }
}
