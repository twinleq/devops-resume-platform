// Health Check and Monitoring
class HealthMonitor {
    constructor() {
        this.healthEndpoint = '/health';
        this.metricsEndpoint = '/metrics';
        this.checkInterval = 30000; // 30 seconds
        this.init();
    }

    init() {
        this.updateHealthStatus();
        this.updateMetrics();
        setInterval(() => this.updateHealthStatus(), this.checkInterval);
        setInterval(() => this.updateMetrics(), this.checkInterval);
    }

    async updateHealthStatus() {
        try {
            const response = await fetch(this.healthEndpoint);
            
            const healthStatus = document.getElementById('healthStatus');
            const healthDot = document.querySelector('.health-dot');
            const healthText = document.querySelector('.health-text');
            
            if (response.ok) {
                const text = await response.text();
                // Проверяем если ответ содержит "healthy" или статус код 200
                if (text.includes('healthy') || response.status === 200) {
                    healthStatus.style.background = 'rgba(16, 185, 129, 0.9)';
                    healthText.textContent = 'System Status: Active';
                } else {
                    healthStatus.style.background = 'rgba(239, 68, 68, 0.9)';
                    healthText.textContent = 'System Status: Unhealthy';
                }
            } else {
                healthStatus.style.background = 'rgba(239, 68, 68, 0.9)';
                healthText.textContent = 'System Status: Unhealthy';
            }
        } catch (error) {
            console.error('Health check failed:', error);
            const healthStatus = document.getElementById('healthStatus');
            const healthText = document.querySelector('.health-text');
            healthStatus.style.background = 'rgba(239, 68, 68, 0.9)';
            healthText.textContent = 'System Status: Unknown';
        }
    }

    async updateMetrics() {
        try {
            // Попробуем сначала API endpoint
            const apiResponse = await fetch('/api/metrics');
            if (apiResponse.ok) {
                const data = await apiResponse.json();
                
                // Update uptime
                const uptimeElement = document.getElementById('uptime');
                if (uptimeElement && data.uptime) {
                    uptimeElement.textContent = data.uptime;
                }
                
                // Update response time
                const responseTimeElement = document.getElementById('response-time');
                if (responseTimeElement && data.response_time) {
                    responseTimeElement.textContent = data.response_time + 'ms';
                }
                
                // Update deployments
                const deploymentsElement = document.getElementById('deployments');
                if (deploymentsElement && data.deployments_today !== undefined) {
                    deploymentsElement.textContent = data.deployments_today;
                }
                
                return;
            }
        } catch (apiError) {
            console.log('API metrics not available, trying Prometheus endpoint');
        }
        
        // Fallback to Prometheus endpoint
        try {
            const response = await fetch(this.metricsEndpoint);
            
            if (response.ok) {
                const text = await response.text();
                
                // Парсим Prometheus метрики
                const lines = text.split('\n');
                let uptime = 3600; // значение по умолчанию
                
                for (const line of lines) {
                    if (line.includes('app_uptime_seconds')) {
                        const match = line.match(/(\d+)/);
                        if (match) {
                            uptime = parseInt(match[1]);
                            break;
                        }
                    }
                }
                
                // Update uptime (конвертируем секунды в часы и минуты)
                const uptimeElement = document.getElementById('uptime');
                if (uptimeElement) {
                    const hours = Math.floor(uptime / 3600);
                    const minutes = Math.floor((uptime % 3600) / 60);
                    uptimeElement.textContent = `${hours}h ${minutes}m`;
                }
                
                // Update response time (симуляция)
                const responseTimeElement = document.getElementById('response-time');
                if (responseTimeElement) {
                    responseTimeElement.textContent = '50ms';
                }
                
                // Update deployments (симуляция)
                const deploymentsElement = document.getElementById('deployments');
                if (deploymentsElement) {
                    deploymentsElement.textContent = '1';
                }
            }
        } catch (error) {
            console.error('Metrics update failed:', error);
        }
    }
}

// Navigation
class Navigation {
    constructor() {
        this.navbar = document.querySelector('.navbar');
        this.hamburger = document.querySelector('.hamburger');
        this.navMenu = document.querySelector('.nav-menu');
        this.navLinks = document.querySelectorAll('.nav-link');
        this.init();
    }

    init() {
        // Mobile menu toggle
        this.hamburger.addEventListener('click', () => {
            this.hamburger.classList.toggle('active');
            this.navMenu.classList.toggle('active');
        });

        // Close mobile menu when clicking on a link
        this.navLinks.forEach(link => {
            link.addEventListener('click', () => {
                this.hamburger.classList.remove('active');
                this.navMenu.classList.remove('active');
            });
        });

        // Navbar scroll effect
        window.addEventListener('scroll', () => {
            if (window.scrollY > 100) {
                this.navbar.style.background = 'rgba(255, 255, 255, 0.98)';
                this.navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.1)';
            } else {
                this.navbar.style.background = 'rgba(255, 255, 255, 0.95)';
                this.navbar.style.boxShadow = 'none';
            }
        });

        // Smooth scrolling for anchor links
        this.navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const targetId = link.getAttribute('href');
                const targetSection = document.querySelector(targetId);
                
                if (targetSection) {
                    const offsetTop = targetSection.offsetTop - 80;
                    window.scrollTo({
                        top: offsetTop,
                        behavior: 'smooth'
                    });
                }
            });
        });
    }
}

// Scroll Animations
class ScrollAnimations {
    constructor() {
        this.init();
    }

    init() {
        // Add scroll animation class to elements
        const elementsToAnimate = document.querySelectorAll('.about-content, .timeline-item, .skill-category, .project-card, .contact-content');
        elementsToAnimate.forEach(element => {
            element.classList.add('scroll-animate');
        });

        // Intersection Observer for scroll animations
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate');
                }
            });
        }, {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        });

        document.querySelectorAll('.scroll-animate').forEach(element => {
            observer.observe(element);
        });
    }
}

// Skill Bars Animation
class SkillBars {
    constructor() {
        this.init();
    }

    init() {
        const skillBars = document.querySelectorAll('.skill-bar');
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const skillBar = entry.target;
                    const level = skillBar.getAttribute('data-level');
                    setTimeout(() => {
                        skillBar.style.width = level + '%';
                    }, 200);
                }
            });
        }, {
            threshold: 0.5
        });

        skillBars.forEach(bar => {
            observer.observe(bar);
        });
    }
}

// Contact Form
class ContactForm {
    constructor() {
        this.form = document.getElementById('contactForm');
        this.init();
    }

    init() {
        if (this.form) {
            this.form.addEventListener('submit', (e) => {
                e.preventDefault();
                this.handleSubmit();
            });
        }
    }

    async handleSubmit() {
        const formData = new FormData(this.form);
        const data = Object.fromEntries(formData);

        // Show loading state
        const submitBtn = this.form.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        submitBtn.textContent = 'Отправка...';
        submitBtn.disabled = true;

        try {
            // Try real API submission first
            const response = await fetch('/api/contact', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });

            const result = await response.json();

            if (result.success) {
                // Show success message
                this.showMessage(result.message || 'Сообщение успешно отправлено!', 'success');
                this.form.reset();
                
                // Log successful submission
                console.log('📧 Message sent successfully:', data);
            } else {
                // Show error message
                this.showMessage(result.error || 'Ошибка при отправке сообщения', 'error');
            }
        } catch (error) {
            console.error('Form submission error:', error);
            
            // Fallback: Show contact information instead of error
            this.showContactInfo(data);
        } finally {
            // Reset button state
            submitBtn.textContent = originalText;
            submitBtn.disabled = false;
        }
    }

    showContactInfo(data) {
        // Show success message with contact info
        const message = `Сообщение готово к отправке!\n\nИмя: ${data.name}\nEmail: ${data.email}\nСообщение: ${data.message}\n\nПожалуйста, отправьте это сообщение на email: twinleq@bk.ru\nили свяжитесь через GitHub: https://github.com/twinleq`;
        
        this.showMessage('Спасибо за сообщение! Поскольку сервер временно недоступен, пожалуйста, отправьте ваше сообщение на email: twinleq@bk.ru', 'success');
        
        // Copy contact info to clipboard
        navigator.clipboard.writeText(message).then(() => {
            console.log('📋 Contact info copied to clipboard');
        }).catch(() => {
            console.log('📋 Contact info ready for manual copy');
        });
        
        this.form.reset();
        
        // Log the message for debugging
        console.log('📧 Message ready for manual sending:', data);
    }

    showMessage(message, type) {
        // Remove existing messages
        const existingMessage = document.querySelector('.form-message');
        if (existingMessage) {
            existingMessage.remove();
        }

        // Create new message
        const messageDiv = document.createElement('div');
        messageDiv.className = `form-message ${type}`;
        messageDiv.textContent = message;
        messageDiv.style.cssText = `
            padding: 1rem;
            margin-top: 1rem;
            border-radius: 8px;
            font-weight: 500;
            ${type === 'success' 
                ? 'background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0;' 
                : 'background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5;'
            }
        `;

        this.form.appendChild(messageDiv);

        // Remove message after 5 seconds
        setTimeout(() => {
            messageDiv.remove();
        }, 5000);
    }
}

// Performance Monitoring
class PerformanceMonitor {
    constructor() {
        this.init();
    }

    init() {
        // Monitor page load performance
        window.addEventListener('load', () => {
            const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
            console.log(`Page load time: ${loadTime}ms`);
            
            // Send performance metrics (in real implementation)
            this.sendMetrics({
                load_time: loadTime,
                timestamp: new Date().toISOString()
            });
        });

        // Monitor Core Web Vitals
        this.monitorCoreWebVitals();
    }

    monitorCoreWebVitals() {
        // Largest Contentful Paint (LCP)
        new PerformanceObserver((entryList) => {
            const entries = entryList.getEntries();
            const lastEntry = entries[entries.length - 1];
            console.log('LCP:', lastEntry.startTime);
        }).observe({ entryTypes: ['largest-contentful-paint'] });

        // First Input Delay (FID)
        new PerformanceObserver((entryList) => {
            const entries = entryList.getEntries();
            entries.forEach(entry => {
                console.log('FID:', entry.processingStart - entry.startTime);
            });
        }).observe({ entryTypes: ['first-input'] });

        // Cumulative Layout Shift (CLS)
        new PerformanceObserver((entryList) => {
            const entries = entryList.getEntries();
            entries.forEach(entry => {
                if (!entry.hadRecentInput) {
                    console.log('CLS:', entry.value);
                }
            });
        }).observe({ entryTypes: ['layout-shift'] });
    }

    sendMetrics(metrics) {
        // In a real implementation, send to monitoring service
        console.log('Sending metrics:', metrics);
    }
}

// Theme Switcher (Optional)
class ThemeSwitcher {
    constructor() {
        this.currentTheme = localStorage.getItem('theme') || 'light';
        this.init();
    }

    init() {
        this.applyTheme(this.currentTheme);
        this.createThemeToggle();
    }

    createThemeToggle() {
        const toggle = document.createElement('button');
        toggle.innerHTML = this.currentTheme === 'light' ? '🌙' : '☀️';
        toggle.style.cssText = `
            position: fixed;
            top: 100px;
            right: 20px;
            background: #4f46e5;
            color: white;
            border: none;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            cursor: pointer;
            font-size: 20px;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
            transition: all 0.3s ease;
        `;

        toggle.addEventListener('click', () => {
            this.toggleTheme();
        });

        document.body.appendChild(toggle);
    }

    toggleTheme() {
        this.currentTheme = this.currentTheme === 'light' ? 'dark' : 'light';
        this.applyTheme(this.currentTheme);
        localStorage.setItem('theme', this.currentTheme);
    }

    applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
    }
}

// Progressive Web App (PWA) Support
class PWA {
    constructor() {
        this.init();
    }

    init() {
        // Register service worker
        if ('serviceWorker' in navigator) {
            window.addEventListener('load', () => {
                navigator.serviceWorker.register('/sw.js')
                    .then(registration => {
                        console.log('SW registered: ', registration);
                    })
                    .catch(registrationError => {
                        console.log('SW registration failed: ', registrationError);
                    });
            });
        }

        // Add to home screen prompt
        this.setupInstallPrompt();
    }

    setupInstallPrompt() {
        let deferredPrompt;
        
        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            deferredPrompt = e;
            
            // Show install button
            this.showInstallButton(deferredPrompt);
        });
    }

    showInstallButton(deferredPrompt) {
        const installBtn = document.createElement('button');
        installBtn.textContent = 'Установить приложение';
        installBtn.style.cssText = `
            position: fixed;
            bottom: 80px;
            right: 20px;
            background: #4f46e5;
            color: white;
            border: none;
            padding: 0.75rem 1rem;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
        `;

        installBtn.addEventListener('click', async () => {
            if (deferredPrompt) {
                deferredPrompt.prompt();
                const { outcome } = await deferredPrompt.userChoice;
                console.log(`User response to the install prompt: ${outcome}`);
                deferredPrompt = null;
                installBtn.remove();
            }
        });

        document.body.appendChild(installBtn);
    }
}

// Avatar Photo Handler
class AvatarHandler {
    constructor() {
        this.init();
    }

    init() {
        this.checkPhotoExists();
    }

    async checkPhotoExists() {
        try {
            const response = await fetch('images/profile-photo.jpg', { method: 'HEAD' });
            const avatarContainer = document.querySelector('.profile-avatar');
            
            if (response.ok) {
                // Photo exists, replace placeholder with image
                const img = document.createElement('img');
                img.src = 'images/profile-photo.jpg';
                img.alt = 'Ромадановский Виталий Денисович';
                img.style.cssText = `
                    width: 120px;
                    height: 120px;
                    border-radius: 50%;
                    object-fit: cover;
                    object-position: center;
                    border: 4px solid #4f46e5;
                    box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
                    transition: transform 0.3s ease;
                `;
                
                img.addEventListener('mouseenter', () => {
                    img.style.transform = 'scale(1.05)';
                });
                
                img.addEventListener('mouseleave', () => {
                    img.style.transform = 'scale(1)';
                });
                
                avatarContainer.innerHTML = '';
                avatarContainer.appendChild(img);
                console.log('✅ Profile photo loaded successfully');
            } else {
                // Photo doesn't exist, keep placeholder
                console.log('📷 Using avatar placeholder with initials');
            }
        } catch (error) {
            console.log('📷 Photo not found, using placeholder:', error);
        }
    }
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Initialize all components
    new Navigation();
    new ScrollAnimations();
    new SkillBars();
    new ContactForm();
    new HealthMonitor();
    new PerformanceMonitor();
    new PWA();
    new AvatarHandler();
    
    // Optional: Initialize theme switcher
    // new ThemeSwitcher();
    
    console.log('DevOps Resume Platform initialized successfully!');
});

// Export for testing (if using modules)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        HealthMonitor,
        Navigation,
        ScrollAnimations,
        SkillBars,
        ContactForm,
        PerformanceMonitor,
        ThemeSwitcher,
        PWA,
        AvatarHandler
    };
}


