import { useEffect, useRef, useState } from 'react';

let reducedMotionPromise: Promise<boolean> | null = null;

function readReducedMotion(): Promise<boolean> {
  if (reducedMotionPromise) return reducedMotionPromise;
  reducedMotionPromise = (async () => {
    if (typeof window === 'undefined' || typeof matchMedia === 'undefined') {
      return false;
    }
    const mq = matchMedia('(prefers-reduced-motion: reduce)');
    if (mq.matches) return true;
    try {
      if (mq.addEventListener) {
        await new Promise<boolean>((resolve) => {
          mq.addEventListener('change', () => resolve(mq.matches), { once: true });
          setTimeout(() => resolve(mq.matches), 0);
        });
        return mq.matches;
      }
      mq.addListener(() => {});
      return false;
    } catch {
      return false;
    }
  })();
  return reducedMotionPromise;
}

export function useReducedMotion() {
  const [reduced, setReduced] = useState<boolean>(() => {
    if (typeof window === 'undefined') return false;
    try {
      return matchMedia('(prefers-reduced-motion: reduce)').matches;
    } catch {
      return false;
    }
  });
  const mountedRef = useRef(true);
  useEffect(() => {
    mountedRef.current = true;
    readReducedMotion().then((value) => {
      if (mountedRef.current) setReduced(value);
    });
    return () => {
      mountedRef.current = false;
    };
  }, []);
  return reduced;
}
