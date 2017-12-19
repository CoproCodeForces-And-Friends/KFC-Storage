using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ProGaudi.Tarantool.Client;
using ProGaudi.Tarantool.Client.Model;
using ProGaudi.Tarantool.Client.Model.Enums;
using StackExchange.Redis;
using StorageWebApplication.Structures;

namespace StorageWebApplication
{
    public static class TarantoolManager
    {
        public static async Task SaveIssue(Issue issue)
        {
            using (var box = await Box.Connect(
                "operator:123123@localhost:3301"))
            {

                try
                {
                    var primaryIndex = box.GetSchema()["issues"]["primary_id"];

                    var rnd = new Random();
                    var num = rnd.Next(3, 10000);
                    await primaryIndex.Insert(TarantoolTuple.Create(num.ToString(), issue.Name));
                }
                catch (ArgumentException)
                {


                }
            }
        }

        public static async Task<Issue[]> GetAllIssues()
        {

            using (var box = await Box.Connect(
                "operator:123123@localhost:3301"))
            {
                var issues = new List<Issue>();
                
                try
                {
                    var primaryIndex = box.GetSchema()["issues"]["primary_id"];
                    var data = await primaryIndex.Select<TarantoolTuple<string>,
                        TarantoolTuple<string, string>>(
                        TarantoolTuple.Create(string.Empty), new SelectOptions
                        {
                            Iterator = Iterator.All
                        });

                    issues.AddRange(data.Data.Select(tuple => new Issue
                    {
                        Id = tuple.Item1,
                        Name = tuple.Item2
                    }));
                }
                catch (ArgumentException)
                {

                }

                return issues.ToArray();
            }
        }
    }
}