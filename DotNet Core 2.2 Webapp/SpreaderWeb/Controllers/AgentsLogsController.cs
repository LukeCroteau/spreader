using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using SpreaderWeb.Models;

namespace SpreaderWeb.Controllers
{
    public class AgentsLogsController : Controller
    {
        private readonly Blaze_dbContext _context;

        public AgentsLogsController(Blaze_dbContext context)
        {
            _context = context;
        }

        // GET: AgentsLogs
        public async Task<IActionResult> Index()
        {
            //var blaze_dbContext = _context.AgentsLog.Include(a => a.Agent).Include(a => a.Job).Include(a => a.LogTypeNavigation).Include(a => a.Worker);
            var blaze_dbContext = _context.AgentsLogViews;
            return View(await blaze_dbContext.OrderByDescending(x => x.AgentsLogCreated).Take(50).ToListAsync());
        }

        // GET: AgentsLogs/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var agentsLog = await _context.AgentsLog
                .Include(a => a.Agent)
                .Include(a => a.Job)
                .Include(a => a.LogTypeNavigation)
                .Include(a => a.Worker)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (agentsLog == null)
            {
                return NotFound();
            }

            return View(agentsLog);
        }

        private bool AgentsLogExists(int id)
        {
            return _context.AgentsLog.Any(e => e.Id == id);
        }
    }
}
