using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using StorageWebApplication.Structures;

namespace StorageWebApplication.Controllers
{
    
    public class DataManger
    {
        private static DataManger instance;
        private readonly JsonSerializer _json;
        public readonly Dictionary<string, Issue> IssuesCollection;
        
        private DataManger()
        {
            IssuesCollection = new Dictionary<string, Issue>();
            _json = JsonSerializer.Create();
            _json.Converters.Add(new StringEnumConverter());
        }


        public static DataManger Instance => instance ?? (instance = new DataManger());

        public string GetJson()
        {

            return JsonConvert.SerializeObject(IssuesCollection);
        }
    }
}