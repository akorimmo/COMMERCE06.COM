// Réglages du site www.commerce06.com — modifiables sans toucher au reste.
export default {
  id: 'commerce06',
  domaine: 'www.commerce06.com',
  nom: 'Commerce06',
  logo: ['Commerce', '06'],
  slogan: 'Fonds de commerce, murs commerciaux, droits au bail et bureaux sur la Côte d’Azur',
  // Agent : recherche « A vendre » + types Commerce, Bureau et Locaux d'activité sur akorimmo.com.
  agent: { types: ['Commerce', 'Bureau', "Locaux d'activité / Entrepôts"], filtre: () => true },
  bien: { singulier: 'local', pluriel: 'commerces et locaux', article: 'un commerce' },
  filtres: { pieces: false, chambres: false },
  couleurs: { accent: '#8f3a1f', accent2: '#2f5a6b', fond: '#f6f2ec', encre: '#251a15' },
  secteurs: ['nice', 'nice-carre-dor', 'nice-promenade-des-anglais', 'nice-cimiez', 'nice-mont-boron', 'nice-nord', 'nice-ouest', 'nice-st-pancrace', 'nice-st-pierre-de-feric', 'aspremont', 'falicon', 'arriere-pays', 'saint-laurent-du-var-a-villeneuve-loubet', 'villefranche-sur-mer-a-menton', 'antibes-a-cannes', 'var'],
  communes: ['06'],
};
