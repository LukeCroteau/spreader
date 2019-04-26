using System;
using System.Collections.Generic;

namespace SpreaderWeb.Models
{
    public partial class JobsLog
    {
        public int Id { get; set; }
        public DateTime? Created { get; set; }
        public int? Jobid { get; set; }
        public int? LogType { get; set; }
        public string Message { get; set; }

        public virtual Jobs Job { get; set; }
        public virtual JobsLogTypes LogTypeNavigation { get; set; }
    }
}
