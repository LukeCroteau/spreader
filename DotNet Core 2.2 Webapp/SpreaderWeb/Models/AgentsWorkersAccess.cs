using System;
using System.Collections.Generic;

namespace SpreaderWeb.Models
{
    public partial class AgentsWorkersAccess
    {
        public int Workerid { get; set; }
        public int Accessid { get; set; }
        public DateTime? Created { get; set; }

        public virtual JobsAccess Access { get; set; }
        public virtual AgentsWorkers Worker { get; set; }
    }
}
