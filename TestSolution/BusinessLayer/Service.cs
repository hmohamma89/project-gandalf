using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BusinessLayer
{
    public interface IService
    {
        bool Counter();
    }
    public class Service : IService
    {
        private readonly string _flag = ConfigurationManager.AppSettings.Get("Flag");
        public bool Counter()
        {
            try
            {
                return Convert.ToBoolean(_flag);
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
