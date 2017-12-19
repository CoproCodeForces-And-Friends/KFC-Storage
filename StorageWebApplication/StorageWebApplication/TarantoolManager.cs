using System;
using System.Threading.Tasks;
using ProGaudi.Tarantool.Client;
using ProGaudi.Tarantool.Client.Model;
using ProGaudi.Tarantool.Client.Model.Enums;
using StorageWebApplication.Structures;

namespace StorageWebApplication
{
    public static class TarantoolManager
    {
        public static async Task DoWork(Issue issue)
        {
            using (var box = await Box.Connect(
                "operator:123123@localhost:3301"))
            {
                //var schema = box.GetSchema();

                //var space = await schema.GetSpace("issues");
                //var primaryIndex = await space.GetIndex("primary_id");

                try
                {
                    var primaryIndex = box.GetSchema()["issues"]["primary_id"];
                     
                    var rnd = new Random();
                    var num = rnd.Next(3, 10000);
                    await primaryIndex.Insert(TarantoolTuple.Create(num.ToString(), issue.Name));

                    var data = await primaryIndex.Select<TarantoolTuple<string>,
                        TarantoolTuple<string, string>>(
                        TarantoolTuple.Create(string.Empty), new SelectOptions
                        {
                            Iterator = Iterator.All
                        });

                    foreach (var item in data.Data)
                    {
                        Console.WriteLine(item);
                    }
                }
                catch (ArgumentException)
                {
                    
                    
                }
            }
        }
    }
}