using Microsoft.EntityFrameworkCore;
using Reposteria.Models;

namespace Reposteria.DB
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Administrador> Administradores { get; set; }
        public DbSet<ClienteFrecuente> ClientesFrecuentes { get; set; }
        public DbSet<Distribuidor> Distribuidores { get; set; }
        public DbSet<LogEvento> LogEventos { get; set; }
        public DbSet<Pedido> Pedidos { get; set; }
        public DbSet<Postre> Postres { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            base.OnConfiguring(optionsBuilder);
            // Habilitar lazy loading con proxies
            optionsBuilder.UseLazyLoadingProxies();
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configurar restricciones y validaciones
            modelBuilder.Entity<Postre>()
                .HasIndex(p => p.Nombre)
                .IsUnique();

            modelBuilder.Entity<Administrador>()
                .HasIndex(a => a.Email)
                .IsUnique();

            modelBuilder.Entity<ClienteFrecuente>()
                .HasIndex(c => c.Email)
                .IsUnique();

            modelBuilder.Entity<Pedido>()
                .HasOne(p => p.ClienteFrecuente)
                .WithMany(cf => cf.Pedidos)
                .HasForeignKey(p => p.ClienteFrecuenteId)
                .OnDelete(DeleteBehavior.SetNull);
        }
    }
}