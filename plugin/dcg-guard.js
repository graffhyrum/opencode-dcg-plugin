import { spawn } from 'child_process';

const callDcgHook = (toolCall) => {
  return new Promise((resolve, reject) => {
    const dcg = spawn('dcg', [], {
      env: { ...process.env, DCG_FORMAT: 'json' }
    });

    let stdout = '';
    let stderr = '';

    dcg.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    dcg.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    dcg.on('close', (code) => {
      if (code === 0) {
        try {
          const result = JSON.parse(stdout);
          resolve(result);
        } catch (e) {
          resolve({ allowed: true });
        }
      } else {
        reject(new Error(stderr || 'dcg blocked command'));
      }
    });

    dcg.stdin.write(JSON.stringify(toolCall));
    dcg.stdin.end();
  });
};

export const DcgGuard = async ({ client }) => {
  return {
    tool: {
      execute: {
        before: async (input, output) => {
          if (input.tool !== 'bash') return;

          const toolCall = {
            tool: 'bash',
            args: { command: output.args.command }
          };

          try {
            await callDcgHook(toolCall);
          } catch (error) {
            throw new Error(
              `🛡️ dcg blocked destructive command: ${output.args.command}\n\n` +
              `${error.message}\n\n` +
              `This command was blocked to protect your system.`
            );
          }
        }
      }
    }
  };
};
