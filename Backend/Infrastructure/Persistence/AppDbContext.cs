using Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Session> Sessions => Set<Session>();
    public DbSet<Transaction> Transactions => Set<Transaction>();
    public DbSet<Goal> Goals => Set<Goal>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
            entity.HasKey(u => u.Id);
            entity.Property(u => u.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(u => u.Name).IsRequired().HasMaxLength(100);
            entity.Property(u => u.Email).IsRequired().HasMaxLength(255);
            entity.Property(u => u.PasswordHash).IsRequired();
            entity.Property(u => u.CreatedAt).HasDefaultValueSql("now()");
            entity.HasIndex(u => u.Email).IsUnique();
        });

        modelBuilder.Entity<Session>(entity =>
        {
            entity.ToTable("sessions");
            entity.HasKey(s => s.Id);
            entity.Property(s => s.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(s => s.DeviceId).IsRequired().HasMaxLength(255);
            entity.Property(s => s.RefreshToken).IsRequired();
            entity.Property(s => s.CreatedAt).HasDefaultValueSql("now()");
            entity.HasIndex(s => new { s.UserId, s.DeviceId });
            entity.HasIndex(s => s.RefreshToken);
            entity.HasOne(s => s.User).WithMany(u => u.Sessions).HasForeignKey(s => s.UserId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.ToTable("transactions");
            entity.HasKey(t => t.Id);
            entity.Property(t => t.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(t => t.Amount).HasColumnType("numeric(18,2)");
            entity.Property(t => t.Type).IsRequired().HasMaxLength(20);
            entity.Property(t => t.Category).IsRequired().HasMaxLength(100);
            entity.Property(t => t.Note).HasMaxLength(500);
            entity.HasIndex(t => new { t.UserId, t.Date });
            entity.HasOne(t => t.User).WithMany(u => u.Transactions).HasForeignKey(t => t.UserId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Goal>(entity =>
        {
            entity.ToTable("goals");
            entity.HasKey(g => g.Id);
            entity.Property(g => g.Id).HasDefaultValueSql("gen_random_uuid()");
            entity.Property(g => g.Title).IsRequired().HasMaxLength(200);
            entity.Property(g => g.Type).IsRequired().HasMaxLength(50);
            entity.Property(g => g.TargetAmount).HasColumnType("numeric(18,2)");
            entity.Property(g => g.CurrentAmount).HasColumnType("numeric(18,2)");
            entity.HasIndex(g => g.UserId);
            entity.HasOne(g => g.User).WithMany(u => u.Goals).HasForeignKey(g => g.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }
}
