using System;
using System.Collections.Generic;

namespace SpreaderWeb.Models
{
    public partial class AgentsLogTypes
    {
        public AgentsLogTypes()
        {
            AgentsLog = new HashSet<AgentsLog>();
        }

        public int Id { get; set; }
        public string Name { get; set; }

        public virtual ICollection<AgentsLog> AgentsLog { get; set; }
    }
}
