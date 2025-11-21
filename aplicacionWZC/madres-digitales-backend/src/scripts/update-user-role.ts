import prisma from '../config/database';

async function updateUserRole() {
  try {
    const email = 'wzuccardi@gmail.com';
    
    // Buscar el usuario
    const user = await prisma.usuarios.findUnique({
      where: { email },
    });

    if (!user) {
      console.log('❌ Usuario no encontrado');
      return;
    }

    console.log('Usuario actual:', {
      email: user.email,
      nombre: user.nombre,
      rol: user.rol,
    });

    // Actualizar a super_admin
    const updated = await prisma.usuarios.update({
      where: { email },
      data: {
        rol: 'SUPER_ADMIN',
      },
    });

    console.log('✅ Usuario actualizado:', {
      email: updated.email,
      nombre: updated.nombre,
      rol: updated.rol,
    });

    await prisma.$disconnect();
  } catch (error) {
    console.error('❌ Error:', error);
    await prisma.$disconnect();
    process.exit(1);
  }
}

updateUserRole();
