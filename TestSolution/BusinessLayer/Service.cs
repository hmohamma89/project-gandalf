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
        private readonly bool _flag = true;
        public bool Counter()
        {
            try
            {
                return _flag;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
