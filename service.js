import chalk from 'chalk';

// ========= CONFIG ==========
const services = ['API', 'DATABASE', 'CACHE', 'AUTH', 'PROXY', 'GUI', 'OOBE', 'RNO', 'APP'];
const totalServices = 20;  // How many services to boot total

// ========= UTILS ==========
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function pickRandom(arr) {
  const index = Math.floor(Math.random() * arr.length);
  return arr[index];
}

// ========= ANIMATIONS ==========
async function countdown(seconds) {
  for (let i = seconds; i > 0; i--) {
    process.stdout.write(`\rStarting in ${i}... `);
    await sleep(1000);
  }
  console.log('\n');
}

async function bootingBar(serviceName, lineNumber) {
  const total = 30;

  for (let i = 0; i <= total; i++) {
    const bar = '#'.repeat(i) + '.'.repeat(total - i);

    // Save cursor, move to line, write bar, restore
    process.stdout.write(`\x1b7`); 
    process.stdout.write(`\x1b[${lineNumber};0H`); 
    process.stdout.write(`[${bar}] ${chalk.red('BOOTING')} [${serviceName}]`);
    process.stdout.write(`\x1b8`);

    await sleep(Math.floor(Math.random() * 100) + 50);
  }

  // ✅ FIXED: Write OK without save/restore, so output stays clean
  process.stdout.write(`\x1b[${lineNumber};0H`);
  process.stdout.write(`${chalk.green('OK')} [${serviceName}]${' '.repeat(total + 20)}\n`);
}

// ========= MAIN ==========
async function main() {
  await countdown(5);

  const tasks = [];

  for (let i = 0; i < totalServices; i++) {
    const serviceName = pickRandom(services);
    const lineNumber = i + 2; // lines 2,3,4...

    // Stagger start times for natural flow
    tasks.push(
      (async () => {
        await sleep(i * 100); // each new service waits i seconds
        await bootingBar(serviceName, lineNumber);
      })()
    );
  }

  await Promise.all(tasks);

  console.log(chalk.green('\nAll services started!'));
}

main();
