using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Razor.Language.Intermediate;
using Newtonsoft.Json;
using StorageWebApplication.Structures;

namespace StorageWebApplication.Controllers
{
    [Route("api/[controller]")]
    public class StorageController : Controller
    {
       
        // GET api/values
        [HttpGet("StoreData")]
        public string Get()
        {
            var t = TarantoolManager.GetAllIssues().Result;
            return DataManger.Instance.IssuesCollection.Count > 0 ? DataManger.Instance.GetJson() : "empty";
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "";
        }

        // POST api/values
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }
        
        [HttpPost("StoreData")]
        public void StoreData([FromBody] Issue value)
        {
            if (value == null)
            {              
                return;
            }

            if (DataManger.Instance.IssuesCollection.ContainsKey(value.Id))
            {
                DataManger.Instance.IssuesCollection[value.Id] = value;
            }
            else
            {
                DataManger.Instance.IssuesCollection.Add(value.Id, value);    
            }

            var t = TarantoolManager.SaveIssue(value);
            Task.WaitAll(new[] {t});
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}