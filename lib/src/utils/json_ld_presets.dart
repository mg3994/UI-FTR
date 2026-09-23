/// Pre-packaged JSON-LD sample payloads showcasing diverse Schema.org types,
/// localization, graph structures, and linked data references.
class JsonLdPresets {
  static const Map<String, Map<String, dynamic>> presets = {
    'Complex Event (Localized)': {
      "@context": {
        "schema": "https://schema.org/",
        "name": "schema:name",
        "description": "schema:description",
        "startDate": "schema:startDate",
        "location": "schema:location",
        "performer": "schema:performer"
      },
      "@graph": [
        {
          "@id": "https://example.com/events/flutter-con-2026",
          "@type": "schema:Event",
          "schema:name": [
            {"@value": "Flutter Global Conference 2026", "@language": "en"},
            {"@value": "Conferencia Global de Flutter 2026", "@language": "es"},
            {"@value": "مؤتمر فلاتر العالمي 2026", "@language": "ar", "@direction": "rtl"}
          ],
          "schema:description": [
            {
              "@value": "Join developers worldwide for the ultimate Flutter architecture summit.",
              "@language": "en"
            },
            {
              "@value": "Únete a desarrolladores de todo el mundo para la cumbre de arquitectura Flutter.",
              "@language": "es"
            },
            {
              "@value": "انضم إلى المطورين من جميع أنحاء العالم في قمة هندسة برمجيات فلاتر.",
              "@language": "ar",
              "@direction": "rtl"
            }
          ],
          "schema:startDate": "2026-10-15T09:00:00Z",
          "schema:endDate": "2026-10-17T18:00:00Z",
          "schema:image": "https://picsum.photos/600/300",
          "schema:url": "https://flutter.dev",
          "schema:location": {
            "@id": "https://example.com/places/convention-center",
            "@type": "schema:Place",
            "schema:name": "Silicon Valley Convention Center",
            "schema:address": "San Jose, CA, USA"
          },
          "schema:performer": {
            "@id": "https://example.com/people/jules-architect",
            "@type": "schema:Person",
            "schema:name": "Jules - UI/UX Architect",
            "schema:jobTitle": "Principal Engineer"
          }
        },
        {
          "@id": "https://example.com/places/convention-center",
          "@type": "schema:Place",
          "schema:name": "Silicon Valley Convention Center (Detail Page)",
          "schema:address": "150 San Carlos St, San Jose, CA 95113",
          "schema:telephone": "+1-408-555-0199"
        },
        {
          "@id": "https://example.com/people/jules-architect",
          "@type": "schema:Person",
          "schema:name": "Jules - UI/UX Architect (Detail Page)",
          "schema:jobTitle": "Senior Software Architect",
          "schema:worksFor": "Global Tech Corp",
          "schema:sameAs": "https://github.com"
        }
      ]
    },
    'Product with Offer': {
      "@context": "https://schema.org",
      "@type": "schema:Product",
      "@id": "https://example.com/products/pro-laptop-2026",
      "schema:name": [
        {"@value": "UltraBook Pro 16-inch", "@language": "en"},
        {"@value": "Portátil Pro 16 Pulgadas", "@language": "es"}
      ],
      "schema:brand": "TechCorp",
      "schema:sku": "TC-PRO-16-2026",
      "schema:image": "https://picsum.photos/500/300",
      "schema:description": "Next generation workstation with high performance processor and OLED screen.",
      "schema:offers": {
        "@type": "schema:Offer",
        "schema:price": 2499.99,
        "schema:priceCurrency": "USD",
        "schema:availability": "https://schema.org/InStock",
        "schema:url": "https://example.com/buy/pro-laptop"
      }
    },
    'Person Profile': {
      "@context": "https://schema.org",
      "@type": "schema:Person",
      "@id": "https://example.com/people/ada-lovelace",
      "schema:name": "Ada Lovelace",
      "schema:jobTitle": "Computing Visionary",
      "schema:worksFor": "Analytical Engine Project",
      "schema:email": "ada@example.com",
      "schema:image": "https://picsum.photos/200/200",
      "schema:sameAs": "https://en.wikipedia.org/wiki/Ada_Lovelace"
    },
    'Gourmet Recipe': {
      "@context": "https://schema.org",
      "@type": "schema:Recipe",
      "@id": "https://example.com/recipes/pasta-carbonara",
      "schema:name": "Authentic Italian Pasta Carbonara",
      "schema:description": "Classic Roman pasta dish made with eggs, hard cheese, cured pork, and black pepper.",
      "schema:prepTime": "PT15M",
      "schema:cookTime": "PT20M",
      "schema:recipeYield": "4 servings",
      "schema:image": "https://picsum.photos/600/350",
      "schema:recipeIngredient": [
        "400g Spaghetti",
        "150g Guanciale or Pancetta",
        "4 large fresh egg yolks",
        "50g Pecorino Romano cheese",
        "Freshly cracked black pepper"
      ],
      "schema:recipeInstructions": [
        "Boil spaghetti in salted water until al dente.",
        "Crisp guanciale in a large skillet over medium heat.",
        "Whisk egg yolks with grated Pecorino Romano and pepper in a bowl.",
        "Combine hot pasta with guanciale and egg mixture off heat until creamy."
      ]
    },
    'User Review': {
      "@context": "https://schema.org",
      "@type": "schema:Review",
      "@id": "https://example.com/reviews/101",
      "schema:reviewBody": "Outstanding Flutter framework for dynamic JSON-LD rendering! Super easy to extend.",
      "schema:reviewRating": {
        "@type": "schema:Rating",
        "schema:ratingValue": 5.0
      },
      "schema:author": {
        "@type": "schema:Person",
        "schema:name": "Senior Software Reviewer"
      },
      "schema:itemReviewed": {
        "@type": "schema:Product",
        "schema:name": "Flutter JSON-LD Framework"
      }
    }
  };
}
